//
//  WelcomeAlert.swift
//  Steve
//
//  Created by Sudhir Kumar on 07/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class WelcomeAlert: UIView {
    // IBOutlets
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Initialization
    class func showWelcomeBoard() {
        let view = Bundle.main.loadNibNamed("WelcomeAlert", owner: self, options: nil)?[0] as! WelcomeAlert
        view.decorateUI()
        view.showAlertView()
        
    }
    
    // MARK: - Custom Method
    private func decorateUI() {
        self.containerView.dropShadow(shadowOffset: CGSize(width: 0, height: 0) , radius: 22, color: CustomColor.alertShadowColor, shadowOpacity: 1.0)
    }
    
    private func showAlertView() {
        let window = kAppDelegate.window
        frame = (window?.bounds)!
        window?.addSubview(self)
        window?.bringSubview(toFront: self)
    }
    
    private func hideAlertView() {
        self.removeFromSuperview()
    }
    
    // MARK: - IBActions
    @IBAction func hideBoard() {
        self.hideAlertView()
    }
}
