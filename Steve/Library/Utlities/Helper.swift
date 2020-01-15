//
//  Helper.swift
//  Steve
//
//  Created by Rishi Kumar on 04/10/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
public let cacheDirectoryURL: URL = {
    let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    return urls[urls.endIndex - 1]
}()
