//
//  AlertView.swift
//  Steve
//
//  Created by Sudhir Kumar on 25/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class AlertView: UIView {
    // IBOutlets
    @IBOutlet weak var alertContainerView: UIView!
    @IBOutlet weak var alertTextLabel: UILabel!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var alertContainerVerticalConstraint:NSLayoutConstraint!
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var alertTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertHeightConstraint: NSLayoutConstraint!
    
    // Variables
    private var actionCount = 0
    var alertCompletion:((Int)->Void)?
    
    // MARK: - Initializers
    class func createAlert() -> AlertView {
        let view = Bundle.main.loadNibNamed("AlertView", owner: self, options: nil)?[0] as! AlertView
        return view
    }
    
    class func showAlertWithMessage(_ title:String = "", _ message:String, buttons:[String], hasBorder:Bool=false, coloredIndex:Int?, completion:((Int)-> Void)?) {
        let view = AlertView.createAlert()
        view.modifyUI()
        if title.count > 0 {
            view.alertTitleLabel.text = title
            view.alertTitleHeightConstraint.constant = 27
            view.alertTitleTopConstraint.constant = 21
        } else {
            view.alertTitleHeightConstraint.constant = 0
            view.alertTitleTopConstraint.constant = 16
        }
        
        view.alertTextLabel.text = message
        if buttons.count > 2 {
            view.buttonStackView.spacing = 10
        }
        view.addActions(actionNames: buttons, hasBorder, coloredIndex)
        view.alertContainerVerticalConstraint.constant = 0
        view.alertCompletion = completion
        view.layoutIfNeeded()
        view.showAlertView()
    }
    
    class func showAlertWithMessageVertical(_ title:String = "", _ message:String, buttons:[String], hasBorder:Bool=false, coloredIndex:Int?, completion:((Int)-> Void)?) {
        let view = AlertView.createAlert()
        view.buttonStackView.axis = .vertical
        view.alertHeightConstraint.constant = 200
        view.modifyUI()
        if title.count > 0 {
            view.alertTitleLabel.text = title
            view.alertTitleHeightConstraint.constant = 27
            view.alertTitleTopConstraint.constant = 21
        } else {
            view.alertTitleHeightConstraint.constant = 0
            view.alertTitleTopConstraint.constant = 16
        }
        
        view.alertTextLabel.text = message
        if buttons.count > 2 {
            view.buttonStackView.spacing = 10
        }
        view.addActions(actionNames: buttons, hasBorder, coloredIndex)
        view.alertContainerVerticalConstraint.constant = 0
        view.alertCompletion = completion
        view.layoutIfNeeded()
        view.showAlertView()
    }
    
    // MARK: - Custom Methods
    private func addActions(actionNames:[String], _ isBorderColor:Bool = false, _ coloredIndex:Int?) {
        var index = 0
        for buttonTitle in actionNames {
            let actionButton = UIButton(type: .system)
            actionButton.setTitle(buttonTitle, for: .normal)
            actionButton.setTitle(buttonTitle, for: .selected)
            actionButton.setTitleColor(CustomColor.preferenceSelectionColor, for: .normal)
            actionButton.setTitleColor(CustomColor.preferenceSelectionColor, for: .selected)
            actionButton.tag = index
            actionButton.roundCorner(radius: 20)
            if isBorderColor {
                actionButton.addPlainBorder(CustomColor.preferenceSelectionColor, lineWidth: 2)
            }
            if coloredIndex != nil && coloredIndex == index {
                actionButton.backgroundColor = CustomColor.preferenceSelectionColor
                actionButton.setTitleColor(.white, for: .normal)
                actionButton.setTitleColor(.white, for: .selected)
            }
            actionButton.titleLabel?.font = UIFont(name: Font.MontserratBold, size: 14.0)
            actionButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            self.buttonStackView.addArrangedSubview(actionButton)
            index += 1
        }
        self.actionCount = index
    }
    
    private func modifyUI() {
        self.alertContainerView.dropShadow(shadowOffset: CGSize(width: 0, height: 0) , radius: 22, color: CustomColor.alertShadowColor, shadowOpacity: 1.0)
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
    
    // MARK: - Actions
    @objc func buttonClicked(btn:UIButton) {
        if self.alertCompletion != nil {
            self.alertCompletion!(btn.tag)
        }
        self.hideAlertView()
    }
    
    // MARK: - Touches
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.actionCount > 1 {
            return
        }
        if let touch = touches.first {
            let touchpoint: CGPoint = touch.location(in: self) // [touch locationInView:self.view];
            
            if !self.alertContainerView.frame.contains(touchpoint) {
                self.hideAlertView()
            }
        }
    }
}
