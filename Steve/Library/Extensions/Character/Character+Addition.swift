//
//  Character+Addition.swift
//  Steve
//
//  Created by Sudhir Kumar on 04/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
// MARK: - Character Extension
public extension Character {

    /**
     If the character represents an integer that fits into an Int, returns
     the corresponding integer.
     */
    public func toInt() -> Int? {
        return Int(String(self))
    }
}
