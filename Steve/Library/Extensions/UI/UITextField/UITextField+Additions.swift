//
//  UITextField+Additions.swift
//  Steve
//
//  Created by Geetika Gupta on 01/04/16.
//  Copyright © 2016 Appster. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UITextField Extension
extension UITextField {

    /**
     Override method of awake from nib to change font size as per aspect ratio.
     */
//    open override func awakeFromNib() {
//
//        super.awakeFromNib()
//
//        if let font = self.font {
//
//            let screenRatio = UIScreen.main.bounds.size.width / CGFloat(320.0)
//            let fontSize = font.pointSize * screenRatio
//
//            self.font = UIFont(name: font.fontName, size: fontSize)!
//        }
//    }

    func isTextFieldEmpty() -> Bool {

        if let str = self.text /* self.textByTrimmingWhiteSpacesAndNewline() */ {
            return str.length == 0
        }
        return true
    }

    func textByTrimmingWhiteSpacesAndNewline() -> String {

        trimWhiteSpacesAndNewline()
        return text ?? ""
    }

    func trimWhiteSpacesAndNewline() {
        let whitespaceAndNewline: CharacterSet = CharacterSet.whitespacesAndNewlines
        let trimmedString: String? = text?.trimmingCharacters(in: whitespaceAndNewline)
        text = trimmedString
    }

    // MARK: Control Actions
    @IBAction func toggleSecureText() {
        isSecureTextEntry = !isSecureTextEntry
    }
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: CustomColor.FloatingLabelTextColor])
        }
    }
}

