//
//  Employers+Services.swift
//  Steve
//
//  Created by Sudhir Kumar on 02/07/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

extension DataManager {
    // APIS
    func searchEmployer(name:String?, email:String?, _ completion: @escaping (_ employer:[Employers]?, _ success: Bool, _ error: Error?) -> Void) {
        let param:[String:Any] = ["name":name ?? "", "email":email ?? ""]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.searchEmployer, params: param) { (response) -> Void in
            self.handleSearchEmployer(response, completion: completion)
        }
    }
    
    func workHistory(name:String?, email:String?, _ completion: @escaping (_ user:User? , _ success: Bool, _ error: Error? ,_ statusCode: Int? ) -> Void) {
        let param:[String:Any] = ["name":name ?? "", "email":email ?? ""]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.workHistoryRequest, params: param) { (response) -> Void in
            self.handleWorkHistory(response, completion: completion)
        }
    }
    
    // Handler
    func handleSearchEmployer(_ response: Response, completion: @escaping (_ employer:[Employers]?, _ success: Bool, _ error: Error?) -> Void) {
        Logger.debug("response = \(response)")
        debugPrint(response.message())
        //let statusCode = response.resultJSON?["statusCode"] as? Int
        if response.success() {
            if let result = response.resultJSON?["result"] as? [Dictionary<String, Any>] {
                if result.count > 0 {
                    do {
                        // Decode retrived data with JSONDecoder
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                        let employer = try JSONDecoder().decode([Employers].self, from: jsonData)
                        completion(employer, true, nil)
                    } catch let jsonError {
                        completion(nil, false, jsonError)
                    }
                } else {
                    completion(nil ,false, response.error)
                }
            } else {
                completion(nil ,false, response.error)
            }
        } else {
            if let x = response.resultJSON?["statusCode"] as? Int {
                if x == 401 {
                    Utilities.logOutUser("")
                }
            }
            completion(nil, false, response.error)
        }
    }
}
