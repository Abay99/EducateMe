//
//  DataManager.swift
//  Steve
//
//  Created by Sudhir Kumar on 04/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

class DataManager {

    let httpClient: HTTPRequestManager
    let isOnline: Bool = true

    // MARK: - Singleton Instance
    class var shared: DataManager {
        struct Singleton {
            static let instance = DataManager()
        }
        return Singleton.instance
    }

    private init() {
        httpClient = HTTPRequestManager.shared
    }
}

extension DataManager {

    /**
     Method used to handle api response and based on the status it calls completion handler

     - parameter response:   api response
     - parameter completion: completion handler
     */
    func handleResponse(_ response: Response, completion: (_ success: Bool, _ message: String?, _ error: Error?) -> Void) {
        Logger.debug("response = \(response)")

        if response.success() {
            completion(true,response.message() ,nil)
        } else {
            completion(false, response.message() ,response.error)
        }
    }

    func performRequest(_ urlString: String, params: [String: String], completion: @escaping (_ success: Bool, _ message: String?, _ error: Error?) -> Void) {

        httpClient.performHTTPActionWithMethod(.POST, urlString: urlString, params: params) { (response) -> Void in

            self.handleResponse(response, completion: completion)
        }
    }
}
