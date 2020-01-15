//
//  UIApplication+Additions.swift
//  Steve
//
//  Created by Arvind Singh on 13/06/17.
//  Copyright © 2017 Appster. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {

    // MARK: Application info methods
    /**
     Get version of application.

     - returns: Version of app
     */
    class func applicationVersion() -> String {
        let info: NSDictionary = Bundle.main.infoDictionary! as NSDictionary
        return info.object(forKey: "CFBundleVersion") as! String
    }

    /**
     Get bundle identifier of application.

     - returns: NSBundle identifier of app
     */
    class func applicationBundleIdentifier() -> NSString {
        return Bundle.main.bundleIdentifier! as NSString
    }

    /**
     Get name of application.

     - returns: Name of app
     */
    class func applicationName() -> String {
        let info: NSDictionary = Bundle.main.infoDictionary! as NSDictionary
        return info.object(forKey: "CFBundleDisplayName") as! String
    }
}
