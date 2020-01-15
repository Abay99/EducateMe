//
//  UIDevice.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {

    // MARK: API helper methods

    public class func deviceID() -> String {

        if let deviceID = UserDefaults.objectForKey("deviceID") as? String {
            return deviceID
        } else {
            let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
            UserDefaults.setObject(deviceID as AnyObject?, forKey: "deviceID")
            return deviceID
        }
    }

    public class func deviceInfo() -> [String: String] {

        var deviceInfo = [String: String]()
        deviceInfo["deviceToken"] = deviceID()
        deviceInfo["deviceType"] = "1"
        return deviceInfo
    }

    /**
     Detect that the app is running on a jailbroken device or not

     - returns: bool value for jailbroken device or not
     */
    public class func isDeviceJailbroken() -> Bool {
        #if arch(i386) || arch(x86_64)
            return false
        #else
            let fileManager = FileManager.default

            if (fileManager.fileExists(atPath: "/bin/bash") ||
                fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
                fileManager.fileExists(atPath: "/etc/apt")) ||
                fileManager.fileExists(atPath: "/private/var/lib/apt/") ||
                fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
                fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") {
                return true
            } else {
                return false
            }
        #endif
    }
}
