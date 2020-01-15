//
//  CustomTextField.swift
//  Steve
//
//  Created by Pardeep Bishnoi on 15/02/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
class CustomTextField: UITextField {
    
    // MARK: - Properties
    var textpadding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 5)
    var placeholderPadding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 5)
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
extension CustomTextField {
    func doIntialSetup() {
        self.layer.cornerRadius = 20.0
        self.clipsToBounds = true
        self.borderStyle = .none
        self.font = UIFont(name: Font.MontserratSemiBold, size: 13.0)
        let attributes = [
            NSAttributedStringKey.font: UIFont(name: Font.MontserratSemiBold, size: 10.0)
        ]
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: attributes) as NSAttributedString
        
        self.textColor = CustomColor.customTextFieldTextColor
        self.backgroundColor = CustomColor.customTextFieldBackgroundColor
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
        return UIEdgeInsetsInsetRect(bounds, textpadding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, placeholderPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, textpadding)
    }
    
    func showError(with message: String, viewController: UIViewController) {
        self.becomeFirstResponder()
        self.layer.shadowColor = CustomColor.red.cgColor
        
        self.layer.borderColor = CustomColor.customTextFieldErrorColor.cgColor
        self.layer.borderWidth = 1.0
        TopMessage.shared.showMessageWithText(text: message, completion: {
            self.layer.shadowColor = UIColor.clear.cgColor
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.borderWidth = 0.0
        })
    }
}
