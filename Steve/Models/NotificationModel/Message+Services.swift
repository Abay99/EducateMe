//
//  Message+Services.swift
//  Steve
//
//  Created by Sudhir Kumar on 18/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

extension DataManager {
    // MARK: - Web services
    func getAllNotification(page:Int, completion:@escaping(_ result:[NotificationData]?, _ sucess:Bool, _ error:Error?, _ statusCode :Int?, _ currentPage:Int, _ totalPages:Int)-> Void) {
        let param = ["page":"\(page)"]
        httpClient.performHTTPActionWithMethod(.GET, urlString: APIServices.notificationList, params:param) { (response) -> Void in
            self.handleNotificationResponse(response, completion: completion)
        }
    }
    
    func setNotificationStatus(completion:@escaping(_ sucess:Bool, _ message:String?, _ error:Error?)-> Void ){
        
    }
    
    // MARK: - Handel Services
    func handleNotificationResponse(_ response: Response, completion: (_ result: [NotificationData]?, _ success: Bool, _ error: Error?, _ statusCode :Int?, _ currentPage:Int, _ totalPages:Int) -> Void) {
        Logger.debug("response = \(response)")
        var totalPages: Int = 1
        var currentPage: Int = 1
        let statusCode = response.resultJSON?["statusCode"] as? Int
        if response.success() {
            // parse the response
            if let result = response.resultJSON?["result"] as? [Dictionary<String, Any>] {
                if result.count > 0 {
                    if let data = result[0]["data"] as? [Dictionary<String, Any>] {
                        do {
                            // Decode retrived data with JSONDecoder
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                            let notif:[NotificationData] = try JSONDecoder().decode([NotificationData].self, from: jsonData)
                            currentPage = ((result[0]["currentPage"] ?? 1) as? Int) ?? 0
                            totalPages = ((result[0]["lastPage"] ?? 1) as? Int) ?? 0
                            completion(notif, true, nil,statusCode, currentPage, totalPages)
                        } catch let jsonError {
                            completion(nil, false, jsonError,statusCode, currentPage, totalPages)
                        }
                    } else {
                        completion(nil, true, nil, statusCode, currentPage, totalPages)
                    }
                } else {
                    completion(nil, true, nil, statusCode, currentPage, totalPages)
                }
            } else {
                completion(nil ,false, response.error,statusCode, currentPage, totalPages)
            }
        } else {
            if let x = response.resultJSON?["statusCode"] as? Int {
                if x == 401 {
                    Utilities.logOutUser("")
                    return
                }
            }
            completion(nil, false, response.error,statusCode,  currentPage, totalPages)
        }
    }
}
