//
//  PreferencesSection.swift
//  Steve
//
//  Created by Sudhir Kumar on 16/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Kingfisher

class PreferencesSection: UITableViewHeaderFooterView {
    // IBOutlets
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var sectionImageView: UIImageView!
    @IBOutlet weak var sectionButton:UIButton!
    
    // Variables
    var completion:((_ tag:Int)-> Void)?
    
    // MARK: - Initialization
    class func section(tag:Int, _ isVisibleArrow:Bool = false) -> PreferencesSection {
        let view = Bundle.main.loadNibNamed(ViewIdentifier.preferencesSection.value, owner: self, options: nil)?[0] as! PreferencesSection
        view.sectionButton.tag = tag
        view.arrowImageView.isHidden = !isVisibleArrow
        view.sectionView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        //view.backgroundColor = CustomColor.headerBackgroundColor
        view.sectionImageView.kf.indicatorType = .activity
        return view
    }
    
    // MARK: - Custom Method
    func decorateSection(section:Int, _ isVisibleArrow:Bool = false) {
        self.sectionButton.tag = section
        self.arrowImageView.isHidden = !isVisibleArrow
        self.sectionView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.backgroundColor = .yellow
        self.sectionImageView.kf.indicatorType = .activity
    }
    
    func setupData(title:String?, image:String?) {
        self.sectionTitleLabel.text = title
        self.sectionImageView.kf.setImage(with: URL(string:image ?? ""), placeholder: UIImage(named:""), options: nil, progressBlock: nil, completionHandler: nil)
    }
    
    func setSelected(_ isSelected:Bool = false) {
        if isSelected {
            self.sectionView.backgroundColor = CustomColor.preferenceSelectionColor
        } else {
            self.sectionView.backgroundColor = .clear
        }
    }
    
    // IBActions
    @IBAction func sectionTapped(btn:UIButton) {
        if self.completion != nil {
            self.completion!(btn.tag)
        }
    }
}
