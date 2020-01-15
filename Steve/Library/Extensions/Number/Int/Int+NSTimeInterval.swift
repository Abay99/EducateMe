//
//  Int+NSTimeInterval.swift
//  Steve
//
//  Created by Sudhir Kumar on 04/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

/**
 NSTimeInterval conversion extensions
 */
public extension Int {

    var seconds: TimeInterval {
        return TimeInterval(self)
    }

    var minutes: TimeInterval {
        return 60 * seconds
    }

    var hours: TimeInterval {
        return 60 * minutes
    }

    var days: TimeInterval {
        return 24 * hours
    }

    var years: TimeInterval {
        return 365 * days
    }
}
