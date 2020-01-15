//
//  JobDetailCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 22/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class JobDetailCell: UITableViewCell {

    // IBOutlets
    @IBOutlet weak var jobImageView: UIImageView!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var jobDescriptionLabel:UILabel!
    @IBOutlet weak var jobButton: UIButton!
    
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    var completion:(()-> Void)?
    
    // MARK: - Initialization
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Custom Method
    func setupData(_ tableData:[String:String],isLastCell:Bool = false, index:Int = 0) {
        self.jobTitleLabel.text = tableData["title"] ?? ""
        self.jobDescriptionLabel.text = tableData["value"] ?? ""
        if self.jobTitleLabel.text!.hasPrefix("youtube")/* == "youtubeLink:"*/ {
            self.jobButton.isHidden = false
            self.jobDescriptionLabel.textColor = CustomColor.preferenceSelectionColor
        } else {
            self.jobDescriptionLabel.textColor = CustomColor.labelDarkTextColorNoAlpha
            self.jobButton.isHidden = true
        }
        self.jobImageView.image = UIImage(named: (index % 2 == 1) ?AppImage.blueRadio : AppImage.greyRadio)
        self.viewTopConstraint.constant = (index == 0) ? self.jobImageView.frame.origin.y + (self.jobImageView.frame.size.height / 2) : 0
        self.viewBottomConstraint.constant = (isLastCell) ? self.constantForUpdatedCell() : 0
        self.layoutIfNeeded()
    }
    
    private func constantForUpdatedCell() -> CGFloat {
        let newHeight = (self.jobImageView.frame.size.height / 2 ) + self.jobImageView.frame.origin.y
        let newConstantSize = self.frame.height - newHeight
        return newConstantSize
    }
    
    // MARK: - IBActioins
    @IBAction func jobButtonAction() {
        if self.completion != nil {
            self.completion!()
        }
    }
}
