//
//  ViewProfileHeader.swift
//  Steve
//
//  Created by Sudhir Kumar on 04/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Kingfisher
import FloatRatingView

class ViewProfileHeader: UIView {

    // IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    // Variables
    var editComplition:(()->Void)?
    
    // MARK: - Initialization
    class func viewHeader() -> ViewProfileHeader {
        let headerView = (Bundle.main.loadNibNamed("ViewProfileHeader", owner: self, options: nil)?[0] as? ViewProfileHeader) ?? ViewProfileHeader.init(frame: CGRect.zero)
        headerView.updateUI()
        return headerView
    }
    
    // MARK: - Custom Method
    private func updateUI() {
        self.profileImageView.kf.indicatorType = .activity
        self.profileImageView.roundSpecificCorner(corners: [.topRight, .bottomRight], cornerRadius: 40)
    }
    
    func configureHeader(userData:User?) {
        var ageText = ""
        if (userData?.age ?? 0) > 0 {
            ageText = "(\(userData!.age!))"
        }
        
        self.nameLabel.text = (userData?.name ?? "")
        self.emailLabel.text = userData?.email ?? ""
        self.genderLabel.text = (((userData?.gender ?? 1) == 1) ? "Male" : "Female") + ageText
        self.phoneLabel.text = userData?.phoneNumber ?? ""
        self.profileImageView.kf.setImage(with: URL(string:userData?.imageUrl ?? ""), placeholder: UIImage(named:AppImage.placehoderRounded), options: nil, progressBlock: nil, completionHandler: nil)
        //self.rating(value: Int((userData?.averageRating ?? 0.0).round()))
        self.ratingView.rating = Double(userData?.averageRating ?? 0.0)
    }
    
//    private func rating(value:Int) {
//        for i in 0..<value {
//            self.ratingViews[i].image = UIImage(named: AppImage.star)
//        }
//    }
    
    // MARK: - IBActions
    @IBAction func editClicked() {
        if self.editComplition != nil {
            self.editComplition!()
        }
    }
}
