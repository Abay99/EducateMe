//
//  CategoryCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 08/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {

    // IBOutlets
    @IBOutlet weak var pointImageView: UIImageView!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var viewMoreButton: UIButton!
    @IBOutlet weak var firstCategoryLabel: UILabel!
    @IBOutlet weak var secondCategoryLabel: UILabel!
    
    @IBOutlet weak var firstViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    // Variables
    var completion:(()->Void)?
    private var parentIds:[Int] = []
    
    // MARK: - Initialization
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Custom Method
    func setupData(_ title:String?, _ categories:[SelectedCategories]?,isLastCell:Bool = false, index:Int = 0) {
        self.parentIds.removeAll()
        self.firstViewHeightConstraint.constant = 0
        self.secondViewHeightConstraint.constant = 0
        self.firstViewTopConstraint.constant = 0
        self.secondViewBottomConstraint.constant = 0
        
        self.jobTitleLabel.text = title ?? ""
        self.pointImageView.image = UIImage(named: (index % 2 == 1) ?AppImage.blueRadio : AppImage.greyRadio)
        self.viewBottomConstraint.constant = (isLastCell) ? self.constantForUpdatedCell() : 0
        self.setupText(categories)
        self.layoutIfNeeded()
    }
    
    private func setupText(_ categories:[SelectedCategories]?) {
        for i in 0..<(categories?.count ?? 0) {
            if !self.parentIds.contains(categories?[i].parentCategoryId ?? 0) {
                if self.parentIds.count == 0 {
                    self.firstCategoryLabel.text = categories?[i].parentCategoryName
                    self.firstViewTopConstraint.constant = 9
                    self.firstViewHeightConstraint.constant = 30
                    self.parentIds.append(categories![i].parentCategoryId!)
                } else if self.parentIds.count == 1 {
                    self.secondCategoryLabel.text = categories?[i].parentCategoryName
                    self.secondViewBottomConstraint.constant = 14
                    self.secondViewHeightConstraint.constant = 30
                    self.parentIds.append(categories![i].parentCategoryId!)
                } else if self.parentIds.count > 1 {
                    self.viewMoreButton.isHidden = false
                    break
                }
            }
        }
    }
    
    private func constantForUpdatedCell() -> CGFloat {
        let newHeight = (self.pointImageView.frame.size.height / 2 ) + self.pointImageView.frame.origin.y
        let newConstantSize = self.frame.height - newHeight
        return newConstantSize
    }
    
    // MARK: - IBActions
    @IBAction func viewMoreClicked() {
        if self.completion != nil {
            self.completion!()
        }
    }
}
