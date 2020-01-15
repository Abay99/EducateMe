//
//  ProfileCollectionCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 15/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

enum HideDirection {
    case none, left, right
}

class ProfileCollectionCell: UICollectionViewCell {

    //IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var lineViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineViewTrailingConstraint: NSLayoutConstraint!
    
    //MARK: - Initializer
    required init(coder: NSCoder?) {
        super.init(coder: coder!)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nib: Array = Bundle.main.loadNibNamed(CellIdentifier.profileColCell.value, owner: self, options: nil)!
        let cell = nib[0] as? UIView
        cell?.frame = bounds
        addSubview(cell!)
    }
    
    // MARK: - Custom Method
    func setHeading(text:String, isSelected:Bool, hide:HideDirection = .none) {
        self.lineViewLeadingConstraint.constant = 0
        self.lineViewTrailingConstraint.constant = 0
        switch hide {
        case .left:
            self.lineViewLeadingConstraint.constant = self.imageView.center.x
        case .right:
            self.lineViewTrailingConstraint.constant = self.imageView.center.x
        default:
            break
        }
        self.layoutIfNeeded()
        
        if isSelected {
            self.imageView.image = UIImage(named: AppImage.blueDot)
            self.titleTextLabel.font = UIFont(name: Font.MontserratSemiBold, size: 12)
            self.titleTextLabel.textColor = CustomColor.profileSelectedTextColor
            self.titleTextLabel.text = text
        } else {
            self.imageView.image = UIImage(named: AppImage.greyDot)
            self.titleTextLabel.font = UIFont(name: Font.MontserratRegular, size: 12)
            self.titleTextLabel.textColor = CustomColor.profileUnselectedTextColor
            self.titleTextLabel.text = text
        }
    }
}
