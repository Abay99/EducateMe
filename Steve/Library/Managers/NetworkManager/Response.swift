//
//  ApiResponse.swift
//  Steve
//
//  Created by Sudhir Kumar on 04/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

/// Response used to store URL response.
class Response {

    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let status = "status"
        static let responseCode = "responseCode"
        static let message = "message"
    }

    // The URL request sent to the server.
    var request: URLRequest?

    // The server's response to the URL request.
    var response: HTTPURLResponse?

    // The data returned by the server.
    var data: Data?

    // The error received during the request.
    var error: Error?

    // The dictionary received after parsing the received data.
    var resultJSON: Dictionary<String, Any>?

    // MARK: - Initialization Methods

    init(_ request: URLRequest, _ response: HTTPURLResponse?, _ data: Data) {
        self.request = request
        self.response = response

        if Utilities.isObjectInitialized(data as AnyObject?) {

            self.data = data

            do {
                // Try parsing some valid JSON
                resultJSON = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary
                if !success() {
                    self.error = error(responseCode(), message())
                }
            } catch let error as NSError {
                // Catch fires here, with an NSErrro being thrown from the JSONObjectWithData method
                debugPrint("A JSON parsing error occurred, here are the details:\n \(error)")
                self.error = error
            }
        }
    }

    init(_ request: URLRequest?, _ response: HTTPURLResponse?, _ error: Error) {
        self.request = request
        self.response = response
        self.error = error
    }

    // MARK: - Getters Methods

    /**
     The response status after parsing the received data.

     - returns: true if success code return
     */
    func success() -> Bool {
        if let resultJSON = resultJSON, let status: String = resultJSON[SerializationKeys.status] as? String {
            if status == "Success" {
                return true
            } else {
                return false
            }
        }
        return false
    }

    /**
     The response string from the received data.

     - returns: Returns the response as a string
     */
    func outputText() -> String? {

        guard let data = data else {
            return nil
        }

        return String(data: data as Data, encoding: String.Encoding.utf8)
    }

    /**
     The responseCode received after parsing the received data.

     - returns: get response code from api response data.
     */
    func responseCode() -> Int {

        if let resultJSON = resultJSON, let code = resultJSON[SerializationKeys.responseCode] as? Int {
            return code
        }

        return -1 // Unknown response code.
    }

    /**
     The message received after parsing the received data.

     - returns: response message from api response data.
     */
    func message() -> String {

        if let resultJSON = resultJSON, let message = resultJSON[SerializationKeys.message] as? String {
            return message
        }

        return (success()) ? NSLocalizedString("Action performed successfully.", comment: "Action performed successfully.") : NSLocalizedString("An error occurred while performing this request. Please try again later.", comment: "An error occurred while performing this request. Please try again later.")
    }

    /**
     The responseError received after parsing the received data.

     - returns: error if api failed.
     */

    fileprivate func error(_ code: Int, _ message: String) -> Error {

        let errorDictionary = [NSLocalizedFailureReasonErrorKey: NSLocalizedString("Error", comment: "Error"), NSLocalizedDescriptionKey: message]
        return NSError(domain: "com.httprequest", code: code, userInfo: errorDictionary)
    }
}
