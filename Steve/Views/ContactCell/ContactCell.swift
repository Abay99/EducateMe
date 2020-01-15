//
//  ContactCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 13/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

enum ContactBy:String {
    case mobile
    case email
}

class ContactCell: UITableViewCell {
    
    // IBOutlets
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellHeightConstraint: NSLayoutConstraint!
    
    // Variables
    var completion:((ContactBy)-> Void)?
    
    // MARK: - Initialization
    class func contactCell() -> ContactCell {
        let view = Bundle.main.loadNibNamed("ContactCell", owner: self, options: nil)?[0] as! ContactCell
        return view
    }
    
    // MARK: - Custom Method
    func configureCell(title:String?) {
        self.titleTextLabel.text = title
    }
    
    func markSelected(_ isSelected:Bool = false) {
//        var newFrame = self.frame
//        if isSelected {
//            newFrame.size.height = 85
//            //self.rotateArrow(true)
//        } else {
//            newFrame.size.height = 0
//            //self.rotateArrow()
//        }
//        self.frame = newFrame
        self.viewHeightConstraint.constant = (isSelected) ? 85 : 0
        self.layoutIfNeeded()
    }
    
    // MARK: - IBActions
    @IBAction func contactAction(sender:UIButton) {
        if self.completion != nil {
            self.completion!((sender.tag == 0) ? .mobile : .email)
        }
    }
    
}
