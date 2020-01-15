//
//  DropDownCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 24/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class DropDownCell: UITableViewCell {
    // IBOutlets
    @IBOutlet weak var menuLabel: UILabel!

    // MARK: - Initialization
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Custom Method
    func configureData(text:String) {
        self.menuLabel.text = text
    }
}
