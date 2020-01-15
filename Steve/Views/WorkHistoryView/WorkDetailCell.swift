//
//  WorkCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 02/07/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class WorkDetailCell: UITableViewCell {

    // IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Initialization
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Custom Method
    func configureCell(data:WorkHistories?) {
        self.backgroundColor = .clear
        guard let history = data else { return }
        self.nameLabel.text = history.employerName ?? ""
        self.emailLabel.text = history.employerEmail ?? ""
        if (history.status ?? 0) == 1 {
            self.statusLabel.text = AppText.approveWork
            self.statusLabel.textColor = CustomColor.backgroundGreen
        } else {
            self.statusLabel.text = AppText.pendingWork
            self.statusLabel.textColor = CustomColor.preferenceSelectionColor
        }
    }
    
}
