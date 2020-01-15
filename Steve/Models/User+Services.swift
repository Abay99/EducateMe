//
//  User+Services.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
import Analytics
// MARK: API Services
extension DataManager {
    
    /**
     Method used to handle user signin and signup api response
     
     - parameter response:   api response
     - parameter completion: completion handler
     */
    func handleSignInSignUpResponse(_ response: Response, completion: (_ result: Dictionary<String, Any>?, _ success: Bool, _ error: Error?, _ statusCode :Int?) -> Void) {
        Logger.debug("response = \(response)")
        debugPrint(response.message())
        let statusCode = response.resultJSON?["statusCode"] as? Int
        if response.success() {
            // parse the response
            if let resultArray : [Dictionary<String, Any>] = response.resultJSON?["result"] as? [Dictionary<String, Any>] {
                if resultArray.count > 0
                {
                    let result = resultArray[0]
                    if let accessToken = result["userToken"] {
                        do {
                            // Decode retrived data with JSONDecoder
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                            let user = try JSONDecoder().decode(User.self, from: jsonData)
                            UserManager.shared.activeUser = user
                            UserManager.shared.accessToken = accessToken as? String
                           //SEGAnalytics.shared().track(Analytics.acquisitionSignUpCompleted )
                            SEGAnalytics.shared().track(Analytics.acquisitionSignUpCompleted, properties: [AnalyticsPorperties.email:user.email, AnalyticsPorperties.id:user.id , AnalyticsPorperties.userType:"employee"])
                            completion(result, true, nil,statusCode)
                        } catch let jsonError {
                            completion(result, false, jsonError,statusCode)
                        }
                    } else {
                        completion(result, false, nil,statusCode)
                    }
                }
                else{
                    completion(nil, true, nil,statusCode)
                }
            } else {
                completion(nil ,false, response.error,statusCode)
            }
        } else {
            if let x = response.resultJSON?["statusCode"] as? Int {
                if x == 401 {
                    Utilities.logOutUser("")
                }
            }
            completion(nil, false, response.error,statusCode)
        }
    }
    
    func handleWorkHistory(_ response: Response, completion: @escaping ( _ user:User? , _ success: Bool, _ error: Error? ,_ statusCode: Int? ) -> Void) {
        
            Logger.debug("response = \(response)")
            debugPrint(response.message())
            let statusCode = response.resultJSON?["statusCode"] as? Int
            if response.success() {
                if let resultResponse = response.resultJSON?["result"] as? [Dictionary<String, Any>] {
                    if resultResponse.count > 0 {
                        let result = resultResponse[0]
                        do {
                            // Decode retrived data with JSONDecoder
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                            let user = try JSONDecoder().decode(User.self, from: jsonData)
                            completion(user, true, nil,statusCode)
                        } catch let jsonError {
                            completion(nil, false, jsonError,statusCode)
                        }
                    } else {
                        if let msg = response.resultJSON?["message"] as? String {
                            var user = User.init()
                            user.workHistoryMsg = msg;
                        completion(user ,false, response.error,statusCode)
                        }
                    }
                } else {
                    completion(nil ,false, response.error,statusCode)
                }
            }
            else {
                 completion(nil ,false, response.error,statusCode)
        }
    }
    
    func handleViewProfile(_ response: Response, completion: @escaping (_ user: User?, _ success: Bool, _ error: Error? ,_ statusCode: Int?) -> Void) {
        Logger.debug("response = \(response)")
        
        
        let statusCode = response.resultJSON?["statusCode"] as? Int
        if response.success() {
            if let resultResponse = response.resultJSON?["result"] as? [Dictionary<String, Any>] {
                if resultResponse.count > 0 {
                    let result = resultResponse[0]
                    do {
                        // Decode retrived data with JSONDecoder
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                        let user = try JSONDecoder().decode(User.self, from: jsonData)
                        completion(user, true, nil,statusCode)
                    } catch let jsonError {
                        completion(nil, false, jsonError,statusCode)
                    }
                } else {
                    
                    completion(nil ,false, response.error,statusCode)
                }
            } else {
                completion(nil ,false, response.error,statusCode)
            }
        } else {
            if let x = response.resultJSON?["statusCode"] as? Int {
                if x == 401 {
                    Utilities.logOutUser("")
                }
            }
            completion(nil, false, response.error,statusCode)
        }
    }
    
    func handleContactInfo(_ response: Response, completion: @escaping (_ info:ContactInfo?, _ success: Bool, _ error: Error? ,_ statusCode: Int?) -> Void) {
        Logger.debug("response = \(response)")
        let statusCode = response.resultJSON?["statusCode"] as? Int
        if response.success() {
            if let resultResponse = response.resultJSON?["result"] as? [Dictionary<String, Any>] {
                if resultResponse.count > 0 {
                    let result = resultResponse[0]
                    do {
                        // Decode retrived data with JSONDecoder
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                        let cInfo = try JSONDecoder().decode(ContactInfo.self, from: jsonData)
                        completion(cInfo, true, nil,statusCode)
                    } catch let jsonError {
                        completion(nil, false, jsonError,statusCode)
                    }
                } else {
                    completion(nil, false, response.error,statusCode)
                }
            } else {
                completion(nil, false, response.error,statusCode)
            }
        } else {
            if let x = response.resultJSON?["statusCode"] as? Int {
                if x == 401 {
                    Utilities.logOutUser("")
                }
            }
            completion(nil, false, response.error,statusCode)
        }
    }
    
    // MARK: User Sign Up
    func registerWithEmail(_ email: String, password: String, completion: @escaping (_ result: Dictionary<String, Any>?, _ success: Bool, _ error: Error? ,_ statusCode: Int?) -> Void) {
        
        let params = ["email": email, "password": password]
        
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.sigupAPI, params: params) { (response) -> Void in
            self.handleSignInSignUpResponse(response, completion: completion)
        }
    }
    
    // MARK: User Sign Up
    func resendVerificationEmail(_ email: String, completion: @escaping (_ success: Bool,_ message: String? ,_ error: Error?) -> Void) {
        
        let params = ["email": email]
        
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.resendVerification, params: params) { (response) -> Void in
            self.handleResponse(response, completion: completion)
        }
    }
    
    
    // MARK: Login using email
    func loginWithEmail(_ email: String, password: String, completion: @escaping (_ result: Dictionary<String, Any>?, _ success: Bool, _ error: Error?, _ statusCode: Int?) -> Void) {
        
        let params = ["email": email, "password": password]
        
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.loginAPI, params: params) { (response) -> Void in
            
            self.handleSignInSignUpResponse(response, completion: completion)
        }
    }
    
    // MARK: Login using email
    func updateStripeCustomerId(_ stripeCustomerId: String, completion: @escaping (_ result: Dictionary<String, Any>?, _ success: Bool, _ error: Error?,_ statusCode: Int? ) -> Void) {
        
        let params = ["stripeCustomerId": stripeCustomerId]
        
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.updateStripeId, params: params) { (response) -> Void in
            
            self.handleSignInSignUpResponse(response, completion: completion)
        }
    }
    
    
    // MARK: Login using social platform
    func socialSignUpWithID(_ facebookId: String, fbAccessToken: String,email: String, name: String, imageUrl: String, completion: @escaping (_ result: Dictionary<String, Any>?, _ success: Bool, _ error: Error?, _ statusCode: Int?) -> Void) {
        
        let params = ["facebookId": facebookId, "fbAccessToken": fbAccessToken,"email": email,"name": name,"imageUrl": imageUrl]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.socialSigupAPI, params: params) { (response) -> Void in
            self.handleSignInSignUpResponse(response, completion: completion)
        }
    }
    
    // MARK: Login using social platform
    func forgotPasswordWithEmailID(_ email: String, completion: @escaping (_ success: Bool,_ message: String? ,_ error: Error?) -> Void) {
        
        let params = ["email": email]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.forgotPasswordAPI, params: params) { (response) -> Void in
            self.handleResponse(response, completion: completion)
        }
    }
    
    // MARK: - Change Password
    func changePassword(_ old:String, _ new:String, completion: @escaping (_ success: Bool,_ message: String? ,_ error: Error?) -> Void) {
        let params = ["password":new, "password_confirmation":new, "current_password":old]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.changePassword, params: params) { (response) -> Void in
            self.handleResponse(response, completion: completion)
        }
    }
    
    // MARK: - Admin ContactInfo
    func contactInfo(_ completion: @escaping (_ info:ContactInfo?, _ success: Bool,_ error: Error?, _ statusCode:Int?) -> Void) {
        httpClient.performHTTPActionWithMethod(.GET, urlString: APIServices.contactInfo, params: nil) { (response) -> Void in
            self.handleContactInfo(response, completion: completion)
        }
    }
    
    // MARK: - Available For job
    func markAvailability(isAvailable:Bool, _ completion: @escaping (_ success: Bool,_ message:String?, _ error: Error?) -> Void) {
        let params = ["isAvailable":isAvailable ? 1 : 0]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.changeAvailability, params: params) { (response) -> Void in
            self.handleResponse(response, completion: completion)
        }
    }
    
    // MARK: Login using social platform
    func socialLoginWithID(_ facebookId: String, fbAccessToken: String, completion: @escaping (_ result: Dictionary<String, Any>?, _ success: Bool, _ error: Error?, _ statusCode: Int?) -> Void) {
        
        let params = ["facebookId": facebookId, "fbAccessToken": fbAccessToken]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.socialLoginAPI, params: params) { (response) -> Void in
            self.handleSignInSignUpResponse(response, completion: completion)
        }
    }
    
    // MARK: Logout
    func logout(_ completion: @escaping (_ success: Bool, _ message:String?  ,_ error: Error?) -> Void) {
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.logout) { (response) -> Void in
            //UserManager.shared.deleteActiveUser()
            self.handleResponse(response, completion: completion)
        }
    }
    
    // MARK: - Show user Profile
    func showProfile(_ completion: @escaping (_ user: User?, _ success: Bool, _ error: Error? ,_ statusCode: Int?) -> Void) {
        httpClient.performHTTPActionWithMethod(.GET, urlString: APIServices.showUserProfile) { (response) -> Void in
            self.handleViewProfile(response, completion: completion)
        }
    }
    
    // MARK: - Update device Token
    func updateToken(token:String, _ completion: @escaping (_ success: Bool, _ message:String?, _ error: Error?) -> Void) {
        let param = ["deviceToken":token]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.updateTocken, params: param) { (response) -> Void in
            self.handleResponse(response, completion: completion)
        }
    }
    
//    func handleAddressResponse(_ response: Response, completion: (_ success: Bool, _ error: Error?) -> Void) {
//        Logger.debug("response = \(response)")
//        if response.success() {
//            if let result: [Any] = response.resultJSON?["result"] as? [Any] {
//                do {
//                    // Decode retrived data with JSONDecoder
//                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
//                    let userAddress: [UserAddressData] = try JSONDecoder().decode([UserAddressData].self, from: jsonData)
//                    UserManager.shared.activeUser.address = userAddress
//                    UserManager.shared.setUserCurrentLocation()
//                    completion(true, nil)
//                }
//                catch let jsonError {
//                    completion(false, jsonError)
//                }
//            }
//            else{
//                completion(false, nil)
//            }
//        }
//        else {
//            if let x = response.resultJSON?["statusCode"] as? Int {
//                if x == 401 {
//                    Utilities.logOutUser("")
//                }
//            }
//            completion(false, response.error)
//        }
//    }
    
    func updatePaymentInfo( accountHolderName:String , accountNumber:String,bsb:String, _ completion: @escaping (_ success: Bool, _ message:String?, _ error: Error?) -> Void) {
        let param = ["account_title":accountHolderName , "account_no":accountNumber , "acc_routing":bsb ] as [String : Any]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.updatePaymentInfoUrl, params: param) { (response) -> Void in
            self.handleResponse(response, completion: completion)
        }
    }
    
//    func getPaymentInfo(token:String, accountHolderName:String , accountNumber:String,bsb:String, _ completion: @escaping (_ success: Bool, _ message:String?, _ error: Error?) -> Void) {
//        let param = ["deviceToken":token ,"accountHolderName":accountHolderName , "accountNumber":accountNumber , "bsb":bsb ]
//        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.updatePaymentInfo, params: param) { (response) -> Void in
//            self.handleResponse(response, completion: completion)
//        }
//    }
}
