//
//  EmployerCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 02/07/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class EmployerCell: UITableViewCell {
    // IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    // MARK: - Initialization
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Custom Method
    func configureEmployerCell(emp:Employers?) {
        guard let employer = emp else { return }
        self.nameLabel.text = employer.name
        self.emailLabel.text = employer.email
    }
}
