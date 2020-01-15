//
//  Error+Network.swift
//  Steve
//
//  Created by Sudhir Kumar on 04/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

// MARK: Error handling methods
extension NSError {

    /**
     Get Error instances if Nil URL.

     - returns: Error instance.
     */
    class func errorForInvalidURL() -> NSError {
        let errorDictionary = [NSLocalizedFailureReasonErrorKey: NSLocalizedString("URL Invalid", comment: "URL Invalid"), NSLocalizedDescriptionKey: NSLocalizedString("URL must not be nil", comment: "URL must not be nil")]
        return NSError(domain: NSURLErrorDomain, code: -1, userInfo: errorDictionary)
    }

    /**
     Get Error instances for NoNetwork.

     - returns: Error instance.
     */
    class func errorForNoNetwork() -> NSError {
        let errorDictionary = [NSLocalizedFailureReasonErrorKey: NSLocalizedString("Network unavailable", comment: "Network unavailable"), NSLocalizedDescriptionKey: NSLocalizedString("Please check internet connection", comment: "Please check internet connection")]
        return NSError(domain: NSURLErrorDomain, code: HTTPRequestErrorCode.httpConnectionError.rawValue, userInfo: errorDictionary)
    }

    /**
     Get Error instances for connectionError.

     - returns: connectionError instance.
     */
    class func networkConnectionError() -> NSError {
        let errorDictionary = [NSLocalizedFailureReasonErrorKey: NSLocalizedString("Connection Error", comment: "Connection Error"), NSLocalizedDescriptionKey: NSLocalizedString("Network error occurred while performing this task. Please try again later.", comment: "Network error occurred while performing this task. Please try again later.")]
        return NSError(domain: "HTTP", code: HTTPRequestErrorCode.httpConnectionError.rawValue, userInfo: errorDictionary)
    }

    /**
     Create an error for response you probably don't want (400-500 HTTP responses for example).

     - parameter code: Code for error.

     - returns: An NSError.
     */
    class func errorForHTTPStatus(_ code: Int) -> NSError {
        let text = NSLocalizedString(HTTPStatusCode(statusCode: code).statusDescription, comment: "")
        let errorDictionary = [NSLocalizedFailureReasonErrorKey: NSLocalizedString("Error", comment: "Error"), NSLocalizedDescriptionKey: text]
        return NSError(domain: "HTTP", code: code, userInfo: errorDictionary)
    }
}
