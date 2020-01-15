//
//  UIView+Loader.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

import MBProgressHUD

// MARK: - UIView Extension
extension UIView {

    // - MARK: - Loading Progress View
    func showLoader() {
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.isSquare = true
        hud.mode = .indeterminate
        // hud.color = Colors.themeColor()
    }

    func hideLoader() {
        MBProgressHUD.hide(for: self, animated: true)
    }
}
