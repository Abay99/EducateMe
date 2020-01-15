//
//  WorkCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 25/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class WorkCell: UITableViewCell {
    // IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameTextField: ProfileTextField!
    @IBOutlet weak var emailTextField: ProfileTextField!

    // Variables
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var completion:((_ actionType:Int)->Void)?
    
    // MARK: - Custom Method
    func decorateCellView() {
        self.containerView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.5)
    }
    
    func configureData(data:WorkHistories?,_ index: Int) {
        self.containerView.tag = index
        guard let history = data else { return }
        self.nameTextField.text = history.employerName ?? ""
        self.emailTextField.text = history.employerEmail?.lowercased() ?? ""
        if (history.status ?? 0) == 1 {
            self.statusLabel.text = AppText.approveWork
            self.statusLabel.textColor = CustomColor.backgroundGreen
        } else {
            self.statusLabel.text = AppText.pendingWork
            self.statusLabel.textColor = CustomColor.preferenceSelectionColor
        }
    }
    
    // MARK: - IBAction
    @IBAction func editClicked() {
        if self.completion != nil {
            self.completion!(1)
        }
    }
    
    @IBAction func deleteClicked() {
        if self.completion != nil {
            self.completion!(2)
        }
    }
}
