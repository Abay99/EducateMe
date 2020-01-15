//
//  JobDetailHeader.swift
//  Steve
//
//  Created by Sudhir Kumar on 21/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class JobDetailHeader: UIView {
    // IBOutlets
    @IBOutlet weak var dateTimeView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceContainer: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var jobStatusButton: UIButton!
    @IBOutlet weak var jobTitleLabel: UILabel!
  
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    // Variables
    var completion:(()->Void)?
    
    // MARK: Initialization
    class func headerView()-> JobDetailHeader {
        let view = Bundle.main.loadNibNamed(ViewIdentifier.jobDetailHeader.value, owner: self, options: nil)?[0] as! JobDetailHeader
        view.modifyUI()
        return view
    }
    
    // MARK: - Custom Method
    func modifyUI() {
        self.dateTimeView.dropShadow(radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.categoryImageView.kf.indicatorType = .activity
        let path = UIBezierPath(roundedRect:categoryImageView.bounds,
                                byRoundingCorners:[.bottomLeft],
                                cornerRadii: CGSize(width: 40, height:  40))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        categoryImageView.layer.mask = maskLayer
        categoryImageView.clipsToBounds = true
    }
    
    func setupData(job:Job?) {
        guard let jobData = job else { return }
        self.categoryImageView.kf.setImage(with: URL(string: jobData.categoryImageUrl ?? ""), placeholder: UIImage(named: ""), options: nil, progressBlock: nil, completionHandler: nil)
        self.dateLabel.text = Utilities.stringFromStringDateWithSuffix(strDate: jobData.jobStartTime ?? "")
        self.timeLabel.text = Utilities.timeStringFromDate(strDate: jobData.jobStartTime ?? "")
        self.distanceLabel.text = String(format:"%.1fkm", jobData.distance ?? 0)
        self.categoryLabel.text = (jobData.categoryName ?? "").uppercased()
        //self.priceLabel.text = String(format: "%.2f", jobData.wagePerHour ?? 0)
        self.priceLabel.text =  jobData.wagePerHour

        self.jobTitleLabel.text = jobData.jobName ?? ""
        if jobData.isApplied == 0 {
            self.setupApplyButton()
        } else {
            self.setupJobStatusButtonUI(status: jobData.status ?? 0)
        }
        self.layoutIfNeeded()
        self.distanceContainer.roundSpecificCorner(corners: [.topLeft, .bottomLeft], cornerRadius: 16)
       
    }
    
    private func setupApplyButton() {
        self.jobStatusButton.layoutIfNeeded()
        self.decorateStatusButton(title: AppText.applyJob, color: CustomColor.buttonGreenColor)
        self.jobStatusButton.isUserInteractionEnabled = true
    }
    
    private func setupJobStatusButtonUI(status:Int) {
        let jobStatus = JobConfirmStatus.init(rawValue: status)
        switch jobStatus! {
        case .pending:
            self.decorateStatusButton(title: AppText.pending, color: CustomColor.buttonGreyColor)
            self.jobStatusButton.isUserInteractionEnabled = false
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
            widthConstraint?.constant = 175
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
            self.jobStatusButton.addPlainBorder(color)
            self.jobStatusButton.setTitleColor(CustomColor.preferenceSelectionColor, for: .normal)
        } else {
            self.jobStatusButton.removeBorder()
            self.jobStatusButton.backgroundColor = color
            self.jobStatusButton.titleLabel?.textColor = .white
        }
    }
    
    // MARK: - IBActions
    @IBAction func jobStatusClicked() {
        if self.completion != nil {
            self.completion!()
        }
    }
}
