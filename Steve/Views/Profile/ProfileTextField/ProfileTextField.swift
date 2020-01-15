//
//  CustomTextField.swift
//  Steve
//
//  Created by Pardeep Bishnoi on 15/02/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
//import UIFloatLabelTextField

class ProfileTextField: UIFloatLabelTextField {
    
    // MARK: - Properties
    let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 5)
    var backgroundView : UIView?
    
    // MARK: - Life Cycle Methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doIntialSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        doIntialSetup()
    }
}

// MARK: Helpers
extension ProfileTextField {
    func doIntialSetup() {
        self.layer.cornerRadius = 20.0
        self.clipsToBounds = true
        self.borderStyle = .none
        //self.font = UIFont(name: Font.MontserratSemiBold, size: 14.0)
        let attributes = [
            NSAttributedStringKey.font: UIFont(name: Font.MontserratSemiBold, size: 10.0), NSAttributedStringKey.foregroundColor: CustomColor.FloatingLabelTextColor
        ]
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: attributes) as NSAttributedString
        
        //self.textColor = CustomColor.customTextFieldTextColor
        self.floatLabelFont = UIFont(name: Font.MontserratSemiBold, size: 10.0)
        self.floatLabelActiveColor = CustomColor.FloatingLabelTextColor
        self.floatLabelPassiveColor = CustomColor.FloatingLabelTextColor
        //self.textColor = CustomColor.customTextFieldTextColor
        self.backgroundColor = CustomColor.profileTextFieldBackgroundColor
        self.layer.borderWidth = 0.0
    }
    
    func disable() {
        self.isEnabled = false
        self.textColor = UIColor.lightGray
    }
    
    func enable() {
        self.isEnabled = true
    }
    
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    func showError(with message: String, viewController: UIViewController) {
        self.becomeFirstResponder()
        self.layer.shadowColor = CustomColor.red.cgColor
        
        self.layer.borderColor = CustomColor.customTextFieldErrorColor.cgColor
        self.layer.borderWidth = 1.0
        
//        viewController.view.showToast(message, duration: 2.0, completion: {
//            self.textColor = UIColor.black
//            self.layer.shadowColor = CustomColor.shadowBlack.cgColor
//        })
    }
}
