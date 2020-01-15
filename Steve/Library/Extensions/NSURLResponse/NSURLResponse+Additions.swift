//
//  NSURLResponse+Additions.swift
//  Steve
//
//  Created by Sudhir Kumar on 04/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

// MARK: - NSURLResponse Extension
extension URLResponse {

    func isHTTPResponseValid() -> Bool {

        if let response = self as? HTTPURLResponse {
            return response.statusCode >= 200 && response.statusCode <= 299
        }
        return false
    }
}
