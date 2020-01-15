//
//  CustomSlider.swift
//  Steve
//
//  Created by Sudhir Kumar on 17/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        //keeps original origin and width, changes height, you get the idea
        let customBounds = CGRect(x: bounds.origin.x + 5, y: bounds.origin.y + 13, width: bounds.size.width - 10, height: 7.0)
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
}
