//
//  NSData+Additions.swift
//  Steve
//
//  Created by Sudhir Kumar on 04/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

// MARK: - NSData Extension
extension Data {

    func json() -> AnyObject? {

        var object: AnyObject?

        do {
            object = try JSONSerialization.jsonObject(with: self, options: []) as? [String: AnyObject] as AnyObject
            // use anyObj here
        } catch {
            debugPrint("json error: \(error)")
        }

        return object
    }

    /**
     Get base 64 strinf from nsdata

     - returns: A NSString
     */
    func toBase64EncodedString() -> String {

        return base64EncodedString(options: [NSData.Base64EncodingOptions()])
    }
}
