//
//  SettingCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 31/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
    
    // IBOutlets
    @IBOutlet weak var settingTitleLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!

    // Variables
    var completion:((Bool)-> Void)?
    
    // MARK: - Intitialization
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Custom Method
    func configureCell(title:String, isVisbleSwitch:Bool = false) {
        self.settingTitleLabel.text = title
        if isVisbleSwitch {
            self.settingSwitch.isHidden = false
            self.settingSwitch.isOn = ((UserManager.shared.activeUser.isAvailable ?? 0) == 0) ? false : true
        } else {
            self.settingSwitch.isHidden = true
        }
    }
    
    // MARK: - IBAction
    @IBAction func switchValueChanged() {
        if self.completion != nil {
            self.completion!(self.settingSwitch.isOn)
        }
    }

}
