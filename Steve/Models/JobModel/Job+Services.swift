//
//  Jobs+Services.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

extension DataManager {
    // Web Services
    // Job near by
    func getJobs (latitude:String, longitude:String, radius:Int, requestPage:Int, keyword:String = "", completion: @escaping (_ result: [Job]?, _ success: Bool, _ error: Error?, _ statusCode :Int?, _ currentPage:Int, _ totalPages:Int) -> Void) {
        let params:[String:Any] = ["latitude": latitude, "longitude":longitude , "radius":radius, "page":requestPage, "searchKeyword":keyword]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.getJobs, params: params) { (response) -> Void in
            self.handleJobResponse(response, completion: completion)
        }
    }
    
    func getDirectJobs (requestPage:Int, completion: @escaping (_ result: [Job]?, _ success: Bool, _ error: Error?, _ statusCode :Int?, _ currentPage:Int, _ totalPages:Int) -> Void) {
        let params:[String:Any] = ["page":requestPage]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.getDirectJobs, params: params) { (response) -> Void in
            self.handleJobResponse(response, completion: completion)
        }
    }
    
    func getDirectJobsCount ( completion: @escaping (_ success: Bool, _ error: Error?, _ totalPages:Int?) -> Void) {
        let params:[String:Any] = [:]
        httpClient.performHTTPActionWithMethod(.GET, urlString: APIServices.getDirectJobsCount, params: params) { (response) -> Void in
            self.handleJobCountResponse(response, completion: completion)
        }
    }
    
    // job details
    func getJobDetails(jobId:Int, lat:String, lng:String, completion: @escaping (_ result: Job?, _ success: Bool,_ message:String?, _ error: Error?, _ statusCode :Int?) -> Void) {
        let params:[String:Any] = ["jobId": "\(jobId)", "latitude":lat, "longitude": lng]
        httpClient.performHTTPActionWithMethod(.GET, urlString: APIServices.getJobDetails, params: params) { (response) -> Void in
            self.handleJobDetailResponse(response, completion: completion)
        }
    }
    
    // Job History
    func getMyJobs(key:Int, page:Int, completion: @escaping (_ result: [Job]?, _ success: Bool, _ error: Error?, _ statusCode :Int?, _ currentPage:Int, _ totalPages:Int) -> Void) {
        let params:[String:Any] = ["statusKeyword": "\(key)", "page":"\(page)"]
        httpClient.performHTTPActionWithMethod(.GET, urlString: APIServices.getMyJobs, params: params) { (response) -> Void in
            self.handleJobResponse(response, completion: completion)
        }
    }
    
    // Apply Job
    func initiateForApply(jobId:Int, completion: @escaping (_ conflictId: Int?, _ success: Bool, _ message:String?, _ error: Error?) -> Void) {
        let params:[String:Any] = ["jobId":jobId]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.applyJob, params: params) { (response) -> Void in
            //self.handleResponse(response, completion: completion)
            self.handleApplyJobResponse(response, completion: completion)
        }
    }
    
    // Cancel Job
    func cancelMyJob(jobId:Int, completion: @escaping (_ success: Bool, _ message:String?, _ error: Error?) -> Void) {
        let params:[String:Any] = ["jobId":jobId]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.cancelJob, params: params) { (response) -> Void in
            self.handleResponse(response, completion: completion)
        }
    }
    
    // Start and Complete job
    func changeJobStatus(jobId:Int, status:Int, completion:@escaping (_ success: Bool, _ message:String?, _ error: Error?) -> Void) {
        let params:[String:Any] = ["jobId":jobId, "statusKeyword":status]
        httpClient.performHTTPActionWithMethod(.POST, urlString: APIServices.changeStatus, params: params) { (response) -> Void in
            self.handleResponse(response, completion: completion)
        }
    }
    
    // MARK: - Handler
    func handleJobResponse(_ response: Response, completion: (_ result: [Job]?, _ success: Bool, _ error: Error?, _ statusCode :Int?, _ currentPage:Int, _ totalPages:Int) -> Void) {
        Logger.debug("response = \(response)")
        var totalPages: Int = 0
        var currentPage: Int = 0
        let statusCode = response.resultJSON?["statusCode"] as? Int
        if response.success() {
            // parse the response
            if let result = response.resultJSON?["result"] as? Dictionary<String, Any> {
                if let data = result["data"] as? [Any] {
                    do {
                        // Decode retrived data with JSONDecoder
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        let job:[Job] = try JSONDecoder().decode([Job].self, from: jsonData)
                        currentPage = result["currentPage"] as! Int
                        totalPages = result["lastPage"] as! Int
                        completion(job, true, nil,statusCode, currentPage, totalPages)
                    } catch let jsonError {
                        completion(nil, false, jsonError,statusCode, currentPage, totalPages)
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
                }
            }
            completion(nil, false, response.error,statusCode,  currentPage, totalPages)
        }
    }
    
    func handleJobDetailResponse(_ response: Response, completion: (_ result: Job?, _ success: Bool, _ message:String?, _ error: Error?, _ statusCode :Int?) -> Void) {
        Logger.debug("response = \(response)")
        let statusCode = response.resultJSON?["statusCode"] as? Int
        if response.success() {
            // parse the response
            if let result = response.resultJSON?["result"] as? [Any] {
                do {
                    // Decode retrived data with JSONDecoder
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    let jobs:[Job] = try JSONDecoder().decode([Job].self, from: jsonData)
                    var job:Job?
                    if jobs.count > 0 {
                        job = jobs[0]
                    }
                    completion(job, true, response.message(), nil,statusCode)
                } catch let jsonError {
                    completion(nil, false, response.message(), jsonError,statusCode)
                }
            } else {
                completion(nil ,false, response.message(),response.error,statusCode)
            }
        } else {
            if let x = response.resultJSON?["statusCode"] as? Int {
                if x == 401 {
                    Utilities.logOutUser("")
                }
            }
            completion(nil, false, response.message(), response.error,statusCode)
        }
    }
    
    func handleApplyJobResponse(_ response: Response, completion: (_ conflictId: Int?, _ success: Bool, _ message:String?, _ error: Error?) -> Void) {
        Logger.debug("response = \(response)")
        var conflictJobId:Int?
        if response.success() {
            // parse the response
            if let result = response.resultJSON?["result"] as? [Any] {
                if result.count > 0 {
                    let dict = result[0] as? [String:Any]
                    conflictJobId = (dict?["conflictingJobId"]) as? Int
                    completion(conflictJobId, true, response.message(), response.error)
                } else {
                    completion(nil, true, response.message(), response.error)
                }
            } else {
                completion(nil, false, response.message(), response.error)
            }
        } else {
            if let x = response.resultJSON?["statusCode"] as? Int {
                if x == 401 {
                    Utilities.logOutUser("")
                }
            }
            completion(nil, false, response.message(), response.error)
        }
    }
    
    func handleJobCountResponse(_ response: Response, completion: (_ success: Bool, _ error: Error?, _ totalPages:Int?) -> Void) {
        Logger.debug("response = \(response)")
        if response.success() {
            // parse the response
            if let result = response.resultJSON?["result"] as? [String:Any] {
                if result.count > 0 {
                    if let count = result["total"] as? Int {
                        completion( true,nil, count);
                    }
                }
                else {
                    completion( false, nil, nil)
                }
            }
        }
        else {
            completion( false, response.error, nil)
        }
    }
}
