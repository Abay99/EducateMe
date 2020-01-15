//
//  JobCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 21/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Kingfisher

enum JobConfirmStatus: Int {
    case pending = 1
    case confirmed = 2
    case startCandidate = 3
    case startEmployer = 4
    //case completed = 5
     case pendingForApproval = 5 // Pending for approval
    case cancelled = 6
    // Local
    case cancelledByEmployer = 7
    case completed = 8 // Completed
    
    //5 completd by employer
}

class JobCell: UITableViewCell {
    // IBOutlets
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var jobDateLabel: UILabel!
    @IBOutlet weak var jobTimeLabel: UILabel!
    @IBOutlet weak var jobDistanceLabel: UILabel!
    @IBOutlet weak var jobPriceLabel: UILabel!
    @IBOutlet weak var jobStatusButton: UIButton!
    
    @IBOutlet weak var jobStatusButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var jobStatusTrailingConstraint: NSLayoutConstraint!

    // Variables
    var jobCompletion:((Int)-> Void)?
    
    // MARK: - Initialization
    class func jobCell() -> JobCell {
        let view = Bundle.main.loadNibNamed(CellIdentifier.jobCell.value, owner: self, options: nil)?[0] as! JobCell
        view.modifyUI()
        return view
    }
    
    func modifyUI() {
        //self.backgroundColor = .blue
        self.cellView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.categoryImageView.kf.indicatorType = .activity
        let path = UIBezierPath(roundedRect:categoryImageView.bounds,
                                byRoundingCorners:[.topRight, .bottomLeft],
                                cornerRadii: CGSize(width: 40, height:  40))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        categoryImageView.layer.mask = maskLayer
    }
    
    // MARK: - Custom Method
    func setupData(job:Job ,index:IndexPath) {
        self.categoryLabel.text = (job.categoryName ?? "").uppercased()
        self.categoryImageView.kf.setImage(with: URL(string:job.categoryImageUrl ?? ""), placeholder: UIImage(named:""), options: nil, progressBlock: nil, completionHandler: nil)
        self.jobTitleLabel.text = job.jobName // "Requirement For A Hotel Staff"
        self.jobDateLabel.text = Utilities.stringFromStringDateWithSuffix(strDate: job.jobStartTime ?? "") //"20th feb"
        self.jobTimeLabel.text = job.jobStartTime ?? ""//Utilities.timeStringFromDate(strDate:job.jobStartTime ?? "") //"09:00am"
        self.jobDistanceLabel.text = String(format: "%.1fkm", job.distance ?? 0)
        //self.jobPriceLabel.text =  String(format: "%.2f", job.wagePerHour ?? 0)
        self.jobPriceLabel.text =  job.wagePerHour
        self.jobStatusButton.tag = index.row
        self.jobStatusButton.isUserInteractionEnabled = true
        if job.isApplied == 0 {
            self.setupApplyButton()
        } else {
            self.setupJobStatusButtonUI(status: job.status ?? 0)
        }
    }
    
    private func setupApplyButton() {
        self.jobStatusButtonWidthConstraint.constant = 143
        self.jobStatusTrailingConstraint.constant = -15
        self.jobStatusButton.layoutIfNeeded()
        self.decorateStatusButton(title: AppText.applyJob, color: CustomColor.buttonGreenColor)
        self.jobStatusButton.isUserInteractionEnabled = true
    }
    
    private func setupJobStatusButtonUI(status:Int) {
        let jobStatus = JobConfirmStatus.init(rawValue: status)
        self.jobStatusButtonWidthConstraint.constant = 143
        self.jobStatusTrailingConstraint.constant = -15
        self.jobStatusButton.layoutIfNeeded()
        switch jobStatus! {
        case .pending:
            self.decorateStatusButton(title: AppText.pending, color: CustomColor.buttonGreyColor)
            self.jobStatusButton.isUserInteractionEnabled = false
            self.jobStatusButtonWidthConstraint.constant = 167
            self.jobStatusTrailingConstraint.constant = -15
            self.jobStatusButton.layoutIfNeeded()
            break
        case .confirmed:
            self.decorateStatusButton(title: AppText.startJob, color: CustomColor.preferenceSelectionColor)
            self.jobStatusButton.isUserInteractionEnabled = true
            break
        case .startCandidate:
            self.decorateStatusButton(title: AppText.started, color: CustomColor.buttonGreyColor)
            self.jobStatusButton.isUserInteractionEnabled = false
            break
        case .startEmployer:
            self.decorateStatusButton(title: AppText.complete, color: CustomColor.preferenceSelectionColor)
            self.jobStatusButton.isUserInteractionEnabled = true
            break
//        case .assigned:
//            self.decorateStatusButton(title: AppText.assigned, color: CustomColor.preferenceSelectionColor, isBorder: true)
//            break
        case .completed:
            self.decorateStatusButton(title: AppText.completed, color: CustomColor.preferenceSelectionColor, isBorder: true)
            self.jobStatusButton.isUserInteractionEnabled = false
            break
        case .cancelled:
            self.decorateStatusButton(title: AppText.cancelled, color: CustomColor.preferenceSelectionColor)
            self.jobStatusButton.isUserInteractionEnabled = false
            break
        case .pendingForApproval:
            self.decorateStatusButton(title: AppText.pendingForApproval, color: CustomColor.buttonGreyColor)
            self.jobStatusButtonWidthConstraint.constant = 178

            self.jobStatusButton.isUserInteractionEnabled = false
            break
        default:
            break
        }
    }
    
    private func decorateStatusButton(title:String, color:UIColor, isBorder:Bool = false) {
        self.jobStatusButton.setTitle(title, for: .normal)
        if isBorder {
            self.jobStatusButton.backgroundColor = .white
            self.jobStatusButton.setTitleColor(color, for: .normal)
            self.jobStatusButton.addPlainBorder(color)
            self.jobStatusButton.titleLabel?.textColor = CustomColor.preferenceSelectionColor
        } else {
            self.jobStatusButton.removeBorder()
            self.jobStatusButton.backgroundColor = color
            self.jobStatusButton.titleLabel?.textColor = .white
        }
    }
    
    // MARK: - IBActions
    @IBAction func jobStatusButtonClicked(btn: UIButton) {
        if self.jobCompletion != nil {
            self.jobCompletion!(btn.tag)
        }
    }
}
