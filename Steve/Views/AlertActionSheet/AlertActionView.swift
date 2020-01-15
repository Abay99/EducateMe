//
//  AlertActionView.swift
//  Steve
//
//  Created by Sudhir Kumar on 25/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class AlertActionView: UIView {
    // IBOutlets
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var actionViewCenterVerticalCons: NSLayoutConstraint!
    @IBOutlet weak var actionViewHeightConstraint: NSLayoutConstraint!
    
    // Variables
    //var alertCompletion:((ActionType)-> Void)?
    
    // MARK: - Initializers
    class func createAlertActionView() -> AlertActionView {
        let view = Bundle.main.loadNibNamed("AlertActionView", owner: self, options: nil)?[0] as! AlertActionView
        return view
    }
    
    class func showSignupActionSheet(completion:((ActionType)-> Void)?) {
        let alertView = AlertActionView.createAlertActionView()
        let memberView = MemberAlert.createAlert()
        memberView.completion = {(actionType) in
            if completion != nil {
                completion!(actionType)
            }
            alertView.hideAlertActionView()
        }
        alertView.updateAlertActionConstraint(memberView)
//        alertView.actionView.bounds = memberView.bounds
//        alertView.actionViewCenterVerticalCons.constant = 0
//        alertView.modifyUI()
//        alertView.actionView.addSubview(memberView)
//        alertView.showAlertActionView()
    }

    class func showConflictActionSheet(completion:((ConfilctAction)->Void)?) {
        let alertView = AlertActionView.createAlertActionView()
        let conflictView = ConflictView.createConflictView()
        conflictView.completion = {(actionType) in
            if completion != nil {
                completion!(actionType)
            }
            alertView.hideAlertActionView()
        }
        alertView.updateAlertActionConstraint(conflictView)
//        alertView.actionView.bounds = conflictView.bounds
//        alertView.actionViewHeightConstraint.constant = conflictView.frame.height
//        alertView.actionViewCenterVerticalCons.constant = 0
//        alertView.modifyUI()
//        alertView.actionView.addSubview(conflictView)
//        alertView.layoutIfNeeded()
//        alertView.showAlertActionView()
    }
    
    private func updateAlertActionConstraint(_ alertView:UIView) {
        self.actionView.bounds = alertView.bounds
        self.actionViewHeightConstraint.constant = alertView.frame.height
        self.actionViewCenterVerticalCons.constant = 0
        self.modifyUI()
        self.actionView.addSubview(alertView)
        self.layoutIfNeeded()
        self.showAlertActionView()
    }
    
    // MARK: - Custom Method
    private func modifyUI() {
        self.actionView.dropShadow(shadowOffset: CGSize(width: 0, height: 0) , radius: 12, color: CustomColor.alertShadowColor, shadowOpacity: 1.0)
    }
    
    private func showAlertActionView() {
        let window = kAppDelegate.window
        frame = (window?.bounds)!
        window?.addSubview(self)
        window?.bringSubview(toFront: self)
    }
    
    private func hideAlertActionView() {
        self.removeFromSuperview()
    }
    
    // MARK: - Toches
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let touchpoint: CGPoint = touch.location(in: self) // [touch locationInView:self.view];
            
            if !self.actionView.frame.contains(touchpoint) {
                self.hideAlertActionView()
            }
        }
    }
}
