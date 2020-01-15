//
//  Profile+Services.swift
//  Steve
//
//  Created by Sudhir Kumar on 17/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
typealias progressCompletionHandler = (_ status:Float) -> Void



extension DataManager {
    // MARK: - API
    // ******************** Category List *********************
    func getCategory(completion: @escaping (_ result: [Preferences]?, _ success: Bool, _ error: Error?) -> Void) {
        httpClient.performHTTPActionWithMethod(.GET, urlString: APIServices.categoryList, params: nil) { (response) -> Void in
            self.handleCategoryResponse(response, completion: completion)
        }
    }
    
    func getDocuemntType(completion: @escaping (_ result: [Document]?, _ success: Bool, _ error: Error?) -> Void) {
        httpClient.performHTTPActionWithMethod(.GET, urlString: APIServices.getDocumentList, params: nil) { (response) -> Void in
            if response.success(){
                if let data = response.resultJSON?["result"] as? [Dictionary<String,Any>] {
                    do {
                        // Decode retrived data with JSONDecoder
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        let list:[Document] = try JSONDecoder().decode([Document].self, from: jsonData)
                        completion(list,true, response.error)
                    } catch let jsonError {
                        completion(nil,false, jsonError)
                    }
                }
                else{
                    completion(nil,false,response.error)
                }
            }
        }
    }
    
    
    func deleteDocuemnt(Params:[String:AnyObject], completion: @escaping ( _ success: Bool, _ error: Error?) -> Void) {
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.deleteDocument, params: Params) { (response) -> Void in
            
            if response.success(){
                completion(true, nil);
            }
            else{
                completion(false,response.error)
            }
        }
    }
    
    
    // ******************** Save Profile *********************
    func saveProfile(_ profile:CreateProfile, completion: @escaping (_ success: Bool,_ error: Error?, _ message:String?, _ statusCode :Int? ) -> Void) {
        
        var param:[String:Any] = ["name":profile.name ?? "","age":profile.age ?? 0,"gender":profile.gender ?? 1,"phoneNumber":profile.phoneNumber ?? "","qualification":profile.qualification ?? "","workExperience":profile.workExperience ?? "","bio":profile.bio ?? "","youtubeLink":profile.youtubeLink ?? "","address":profile.address ?? "","latitude":profile.latitude ?? "","longitude":profile.longitude ?? "","radius":profile.radius ?? 50,"category":profile.category ?? [],"image":profile.image ?? ""]
        
        
       // if UserManager.shared.getDocEditingStatus() == true {
        if let docParms = UserManager.shared.getUserUploadedDoc() {
            if docParms.count > 0 {
                param.updateValue(docParms, forKey: "documents")
            }
            else {
                param.updateValue(" ", forKey: "documents")
            }
        }
            UserManager.shared.clearSaveDocEditing()
       // }
       
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.createProfile, params: param) { (response) -> Void in
            self.handleSaveProfileResponse(response, completion: completion)
            //self.handleResponse(response, completion:completion)
        
        }
    }
    
    
    
    
    //    class  func uploadUserDocWithUploadTaskOld(_ fileParams: [String: AnyObject]?, dataField:[String: String]? , completion: @escaping (_ success: Bool, _ error: Error? , _ videoData:Document?) -> (Void))
    //    {
    //        var request: URLRequest = URLRequest(url: URL(string: APIServices.uploadDocument)!)
    //         //let request = URLRequest.requestWithURL(URL(string: APIServices.uploadDocument)!, method: method, jsonDictionary: finalParams as NSDictionary?)
    //        request.setMultipartFormData(dataField, [fileParams!])
    //        var editedRequest = request
    //        // Set required headers
    //        if UserManager.shared.isLoggedInUser() {
    //            if let request = request as? URLRequest {
    //                editedRequest.setValue(UserManager.shared.accessToken!, forHTTPHeaderField: "userToken")
    //                debugPrint(UserManager.shared.accessToken)
    //            }
    //        } else {
    //            editedRequest.setValue("0", forHTTPHeaderField: "userToken")
    //        }
    //        let requestManager = HTTPRequestManager.shared
    //        //requestManager.progressStatusHandller = progressStatus
    //        requestManager.performRequest(editedRequest, userInfo: nil) { (response) -> Void in
    //            _ = String.init(data: response.data!, encoding: String.Encoding.utf8);
    //            //Logger.log(.QA, properties: str as AnyObject);
    //            if response.success(){
    //                do {
    //                    // Decode retrived data with JSONDecoder
    //                    let jsonData = try JSONSerialization.data(withJSONObject: response.data, options: .prettyPrinted)
    //                    let obj:Document = try JSONDecoder().decode(Document.self, from: jsonData)
    //                    //let category:[CategoryList]? = list.categories
    //                    completion(true, response.error, obj)
    //                } catch let jsonError {
    //                    completion(false, jsonError, nil)
    //                }
    //            }
    //            else{
    //                completion(false,response.error ,nil)
    //            }
    //        }
    //    }
    
    
    func uploadUserDocWithUploadTask(_ fileParams: [String: AnyObject]?, dataField:[String: String]? , completion: @escaping (_ success: Bool, _ error: Error? , _ videoData:Document?) -> (Void))
    {
        var request = URLRequest.requestWithURL(URL(string: APIServices.uploadDocument)!, method: .POST, jsonDictionary: dataField as NSDictionary?)
        request.setMultipartFormData(dataField, fileFields: [fileParams!])
        
        let requestManager = HTTPRequestManager.shared
        //requestManager.progressStatusHandller = progressStatus
        requestManager.performRequest(request, userInfo: nil) { (response) -> Void in
            //_ = String.init(data: response.data!, encoding: String.Encoding.utf8);
            //Logger.log(.QA, properties: str as AnyObject);
            if response.success(){
                do {
                    if let data = response.resultJSON?["result"] as? Dictionary<String,Any> {
                        // Decode retrived data with JSONDecoder
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        let obj:Document = try JSONDecoder().decode(Document.self, from: jsonData)
                        completion(true, response.error, obj);
                    }
                } catch let jsonError {
                    completion(false, jsonError, nil)
                }
            }
            else{
                completion(false,response.error ,nil)
            }
        }
    }
    
    
    
    // MARK: - Handler
    func handleCategoryResponse(_ response: Response, completion: (_ result: [Preferences]?, _ success: Bool, _ error: Error?) -> Void) {
        Logger.debug("response = \(response)")
        if response.success() {
            // parse the response
            if let result = response.resultJSON?["result"] as? Dictionary<String, Any> {
                if let data = result["categories"] as? [Dictionary<String,Any>] {
                    do {
                        // Decode retrived data with JSONDecoder
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        let list:[Preferences] = try JSONDecoder().decode([Preferences].self, from: jsonData)
                        //let category:[CategoryList]? = list.categories
                        completion(list, true, nil)
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
    
    // save profile response
    func handleSaveProfileResponse(_ response: Response, completion: (_ success: Bool, _ error: Error?,_ message:String?, _ statusCode :Int?) -> Void) {
        Logger.debug("response = \(response)")
        debugPrint(response.message())
        let statusCode = response.resultJSON?["statusCode"] as? Int
        if response.success() {
            // parse the response
            UserManager.shared.deleteUserUploadedDocFromLocal()
            if let resultArray : [Dictionary<String, Any>] = response.resultJSON?["result"] as? [Dictionary<String, Any>] {
                if resultArray.count > 0
                {
                    let result = resultArray[0]
                    if let accessToken = UserManager.shared.accessToken {
                        do {
                            // Decode retrived data with JSONDecoder
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                            let user = try JSONDecoder().decode(User.self, from: jsonData)
                            UserManager.shared.activeUser = user
                            UserManager.shared.accessToken = accessToken
                            //                            UserManager.shared.setUserCurrentLocation()
                            completion(true, nil,response.message(),statusCode)
                        } catch let jsonError {
                            completion(false, jsonError,nil,statusCode)
                        }
                    } else {
                        completion(false, nil,nil,statusCode)
                    }
                }
                else{
                    completion(true, nil,nil,statusCode)
                }
            } else {
                completion(false, response.error,nil,statusCode)
            }
        } else {
            if let x = response.resultJSON?["statusCode"] as? Int {
                if x == 401 {
                    Utilities.logOutUser("")
                }
            }
            completion(false, response.error,nil,statusCode)
        }
    }
}
