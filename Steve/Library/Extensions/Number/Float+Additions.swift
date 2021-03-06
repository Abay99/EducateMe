//
//  Float+Additions.swift
//  Steve
//
//  Created by Sudhir Kumar on 04/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

// MARK: - Float Extension
public extension Float {
    /**
     Absolute value.

     - returns: fabs(self)
     */
    func abs() -> Float {
        return Swift.abs(self)
    }

    /**
     Squared root.

     - returns: sqrtf(self)
     */
    func sqrt() -> Float {
        return sqrtf(self)
    }

    /**
     Rounds self to the largest integer <= self.

     - returns: floorf(self)
     */
    func floor() -> Float {
        return floorf(self)
    }

    /**
     Rounds self to the smallest integer >= self.

     - returns: ceilf(self)
     */
    func ceil() -> Float {
        return ceilf(self)
    }

    /**
     Rounds self to the nearest integer.

     - returns: roundf(self)
     */
    func round() -> Float {
        return roundf(self)
    }

    /**
     Clamps self to a specified range.

     - parameter min: Lower bound
     - parameter max: Upper bound
     - returns: Clamped value
     */
    func clamp(_ min: Float, _ max: Float) -> Float {
        return Swift.max(min, Swift.min(max, self))
    }

    /**
     Random float between min and max (inclusive).

     - parameter min:
     - parameter max:
     - returns: Random number
     */
    static func random(_ min: Float = 0, max: Float) -> Float {
        let diff = max - min
        let rand = Float(arc4random() % (UInt32(RAND_MAX) + 1))
        return ((rand / Float(RAND_MAX)) * diff) + min
    }
}
