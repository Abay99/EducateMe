//
//  WorkViewCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 02/07/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class WorkViewCell: UITableViewCell {

    // IBOutlets
    @IBOutlet weak var jobImageView: UIImageView!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var workHistoryView: WorkHistoryView!
    
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Initialization
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Custom Method
    func setupData(_ tableData:[String:String],history:[WorkHistories], isLastCell:Bool = false, index:Int = 0) {
        self.jobTitleLabel.text = tableData["title"] ?? ""
        self.workHistoryView.setupWorkData(histories:history)
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
}
