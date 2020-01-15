//
//  UITextField+Designable.swift
//  Steve
//
//  Created by Parth Grover on 3/6/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

@IBDesignable

class UITextField_Designable: CustomTextField {

    @IBInspectable var leftImage: UIImage? {
        didSet{
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0{
        didSet{
            updateView()
        }
    }
    
    func updateView(){
        if let image = leftImage{
            leftViewMode = .always
            let imageView = UIImageView(frame:CGRect(x:leftPadding, y:16, width:14, height:14))
            imageView.image = image
            var width = leftPadding + 14
            if borderStyle == UITextBorderStyle.none || borderStyle == UITextBorderStyle.line{
                width = width + 15.0
            }
            let view = UIImageView(frame:CGRect(x:0, y:0, width:width, height:44))
            view.addSubview(imageView)
            leftView = view
        }
        else{
            // image is nil
            leftViewMode = .never
        }
    }
}
