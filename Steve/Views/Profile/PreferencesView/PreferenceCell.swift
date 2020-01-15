//
//  PreferenceCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 16/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class PreferenceCell: UITableViewCell {

    // IBOutlets

    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    // MARK: - Initialization
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Custom Method
    func configureData(_ data:JobCategories?) {
        guard let list = data else { return }
        self.categoryNameLabel.text = list.name
        self.setJobSelected(list.isJobSelected ?? false)
    }
    
    func configureEditData(_ data:JobCategories?, isSelected:Bool = false) {
        guard let list = data else { return }
        self.categoryNameLabel.text = list.name
        self.setJobSelected(isSelected)
    }
    
    func setJobSelected(_ isSelected:Bool = false) {
        if isSelected {
            self.categoryView.backgroundColor = CustomColor.preferenceSelectionColor
        } else {
            self.categoryView.backgroundColor = .white
        }
    }
}
