//
//  HTTPRequestManager.swift
//  Steve
//
//  Created by Sudhir Kumar on 04/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Reachability

public enum HTTPRequestErrorCode: Int {

    case httpConnectionError = 40 // Trouble connecting to Server.
    case httpInvalidRequestError = 50 // Your request had invalid parameters.
    case httpResultError = 60 // API result error (eg: Invalid username and password).
}

final class HTTPRequestManager {

    fileprivate var urlSession: URLSession
    fileprivate var runningURLRequests: NSSet

    fileprivate var networkFetchingCount: Int = 0

    // MARK: - Singleton Instance

    class var shared: HTTPRequestManager {
        struct Singleton {
            static let instance = HTTPRequestManager()
        }
        return Singleton.instance
    }

    // MARK: - Class Methods

    fileprivate func beginNetworkActivity() {
        networkFetchingCount += 1
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    /**
     Call to hide network indicator in Status Bar
     */
    fileprivate func endNetworkActivity() {
        if networkFetchingCount > 0 {
            networkFetchingCount -= 1
        }

        if networkFetchingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    fileprivate init() {
        // customize initialization

        // Craete Urlsession from default configuration.
        urlSession = URLSession(configuration: URLSessionConfiguration.default)
        // urlSession?.sessionDescription! = "networkmanager.nsurlsession"

        // This will hold the currently running requests
        runningURLRequests = NSSet()
    }

    /**
     Setting Authorization HTTP Request Header
     */
    func setAuthorizationHeader() {
        // TODO: uncomment when using authorization header
        // Set the http header field for authorization
        // setValue("Token token=usertoken", forHTTPHeaderField: "Authorization")
    }

    /**
     Add additional parameters to an existing dictionary

     - parameter params: parameters dictionary

     - returns: returns final dictionary
     */
    func addAdditionalParameters(_ params: [String: Any]?) -> [String: Any] {

        var finalParams = params ?? [:]
        let deviceInfo = UIDevice.deviceInfo()

        for key in deviceInfo.keys {
            if let value = deviceInfo[key] {
                finalParams[key] = value
            }
        }
        if UserDefaults.string(forKey: AppText.deviceToken).count > 0 {
            finalParams[AppText.deviceToken] = UserDefaults.string(forKey: AppText.deviceToken)
        } else {
            if let newValue = (finalParams[AppText.deviceToken] as? String)?.replace("-", replacementString: "") {
                finalParams[AppText.deviceToken] = newValue
            }
        }
        return finalParams
    }

    // MARK: - Public Methods
    /**
     Perform request to fetch data

     - parameter request:           request
     - parameter userInfo:          userinfo
     - parameter completionHandler: handler
     */
    func performRequest(_ request: URLRequest, userInfo _: NSDictionary? = nil, completionHandler: @escaping (_ response: Response) -> Void) {
        guard isNetworkReachable() else {
            let res = Response(request, nil, NSError.errorForNoNetwork())
            completionHandler(res)
            return // do not proceed if user is not connected to internet
        }

        var editedRequest = request
        // Set required headers
         if UserManager.shared.isLoggedInUser() {
             if let request = request as? URLRequest {
                editedRequest.setValue(UserManager.shared.accessToken!, forHTTPHeaderField: "userToken")
                debugPrint(UserManager.shared.accessToken)
             }
         } else {
            editedRequest.setValue("0", forHTTPHeaderField: "userToken")
        }

        performSessionDataTaskWithRequest(editedRequest, completionHandler: completionHandler)
    }

    /**
     Perform session data task

     - parameter request:           url request
     - parameter userInfo:          user information
     - parameter completionHandler: completion handler
     */
    fileprivate func performSessionDataTaskWithRequest(_ request: URLRequest, userInfo: NSDictionary? = nil, completionHandler: @escaping (_ response: Response) -> Void) {

        beginNetworkActivity()
        addRequestedURL(request.url!)

        urlSession.dataTask(with: request, completionHandler: { data, response, error in

            var responseError: Error? = error
            // handle http response status
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode > 299 {
                    responseError = NSError.errorForHTTPStatus(httpResponse.statusCode)
                }
            }

            var apiResponse: Response
            if let _ = responseError {
                apiResponse = Response(request, response as? HTTPURLResponse, responseError!)
                self.logError(apiResponse.error!, request: request)
            } else {
                apiResponse = Response(request, response as? HTTPURLResponse, data!)
                self.logResponse(data!, forRequest: request)
            }

            self.removeRequestedURL(request.url!)

            DispatchQueue.main.async(execute: { () -> Void in
                self.endNetworkActivity()
                completionHandler(apiResponse)
            })
        }).resume()
    }

    /**
     Perform http action for a method

     - parameter method:            HTTP method
     - parameter urlString:         url string
     - parameter params:            parameters
     - parameter completionHandler: completion handler
     */
    func performHTTPActionWithMethod(_ method: HTTPRequestMethod, urlString: String, params: [String: Any]? = nil, completionHandler: @escaping (_ response: Response) -> Void) {

        let finalParams = addAdditionalParameters(params)

        if method == .GET {
            var components = URLComponents(string: urlString)
            components?.queryItems = finalParams.queryItems() as [URLQueryItem]?

            if let url = components?.url {
                var request = URLRequest(url: url)
                request.httpMethod = HTTPRequestMethod.GET.rawValue
                performRequest(request, completionHandler: completionHandler)
            } else { // do not proceed if the url is nil
                let res = Response(nil, nil, NSError.errorForInvalidURL())
                completionHandler(res)
            }
        } else {
            let request = URLRequest.requestWithURL(URL(string: urlString)!, method: method, jsonDictionary: finalParams as NSDictionary?)
            performRequest(request, completionHandler: completionHandler)
        }
    }

    fileprivate func logError(_ error: Error, request: URLRequest) {
        #if DEBUG
            debugPrint("URL: \(String(describing: request.url?.absoluteString)) Error: \(error.localizedDescription)")
        #endif
    }

    fileprivate func logResponse(_ data: Data, forRequest request: URLRequest) {
        #if DEBUG
            debugPrint("Data Size: \(data.count) bytes")
            let output: NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
            debugPrint("URL: \(String(describing: request.url?.absoluteString)) Output: \(output)")
        #endif
    }
   
}

// MARK: Request handling methods
extension HTTPRequestManager {

    /**
     Add a Url to request Manager.

     - parameter url: URL
     */
    fileprivate func addRequestedURL(_ url: URL) {
        objc_sync_enter(self)
        if let requests: NSMutableSet = runningURLRequests.mutableCopy() as? NSMutableSet {
            requests.add(url)
            runningURLRequests = requests
        }
        objc_sync_exit(self)
    }

    /**
     Remove url from Manager.

     - parameter url: URL
     */
    fileprivate func removeRequestedURL(_ url: URL) {
        objc_sync_enter(self)
        if let requests: NSMutableSet = runningURLRequests.mutableCopy() as? NSMutableSet {
            if requests.contains(url) == true {
                requests.remove(url)
                runningURLRequests = requests
            }
        }
        objc_sync_exit(self)
    }

    /**
     Check wheather requesting fro URL.

     - parameter URl: url to check.

     - returns: true if current request.
     */
    fileprivate func isProcessingURL(_ url: URL) -> Bool {
        return runningURLRequests.contains(url)
    }

    /**
     Cancel session for a URL.

     - parameter url: URL
     */
    func cancelRequestForURL(_ url: URL) {
        urlSession.getTasksWithCompletionHandler({ (dataTasks: [URLSessionDataTask], uploadTasks: [URLSessionUploadTask], downloadTasks: [URLSessionDownloadTask]) -> Void in

            let capacity: NSInteger = dataTasks.count + uploadTasks.count + downloadTasks.count
            let tasks: NSMutableArray = NSMutableArray(capacity: capacity)
            tasks.addObjects(from: dataTasks)
            tasks.addObjects(from: uploadTasks)
            tasks.addObjects(from: downloadTasks)
            let predicate: NSPredicate = NSPredicate(format: "originalRequest.URL = %@", url as CVarArg)
            tasks.filter(using: predicate)

            for case let task as URLSessionTask in tasks {
                task.cancel()
            }
        })
    }

    /**
     Cancel All Running Requests
     */
    func cancelAllRequests() {
        urlSession.invalidateAndCancel()
    }
}

// MARK: Network reachable methods
extension HTTPRequestManager {

    /**
     Check wheather network is reachable.

     - returns: true is reachable otherwise false.
     */
    fileprivate func isNetworkReachable() -> Bool {
        let reach: Reachability = Reachability.forInternetConnection()
        return reach.currentReachabilityStatus() != .NotReachable
    }

    /**
     Check wheather WiFi is reachable.

     - returns: true is reachable otherwise false.
     */
    fileprivate func isReachableViaWiFi() -> Bool {
        let reach: Reachability = Reachability.forInternetConnection()
        return reach.currentReachabilityStatus() != .ReachableViaWiFi
    }
}
