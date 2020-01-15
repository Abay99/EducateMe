//
//  UISearchBar + Extension.swift
//  Steve
//
//  Created by Parth Grover on 3/14/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
import UIKit

extension UISearchBar {
    
    func change(textFont : UIFont?) {
        
        for view : UIView in (self.subviews[0]).subviews {
            
            if let textField = view as? UITextField {
                textField.font = textFont
            }
        }
    }
    
    func changeColor(textColor : UIColor?){
        for view : UIView in (self.subviews[0]).subviews {
            
            if let textField = view as? UITextField {
                textField.textColor = textColor
            }
        }
    }
    
}
