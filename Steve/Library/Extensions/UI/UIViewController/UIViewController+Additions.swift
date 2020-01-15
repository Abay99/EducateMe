//
//  UIViewController+Additions.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

extension UIViewController {
    /**
     Shows top view controller

     - parameter rootViewController:      base view controller presented set on window
     */
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            #if os(iOS)
                let moreNavigationController = tab.moreNavigationController

                if let top = moreNavigationController.topViewController, top.view.window != nil {
                    return topViewController(top)
                } else if let selected = tab.selectedViewController {
                    return topViewController(selected)
                }
            #else
                guard let selected = tab.selectedViewController else { return nil }
                return topViewController(selected)
            #endif
        }

        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }

        return base
    }
}
