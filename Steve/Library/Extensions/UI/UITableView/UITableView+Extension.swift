//
//  UITableView+Extension.swift
//  Steve
//
//  Created by Sudhir Kumar on 30/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor().colorWithRedValue(140, greenValue: 148, blueValue: 156, alpha: 1.0)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: Font.MontserratSemiBold, size: 25)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
