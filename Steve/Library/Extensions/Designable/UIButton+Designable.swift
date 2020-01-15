//
//  UIButton+Designable.swift
//  Steve
//
//  Created by Pardeep Bishnoi on 19/02/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
extension UIButton {
    
     @IBInspectable override var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable override var borderColor: UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            return self.borderColor
        }
    }
    
    @IBInspectable override var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
}
