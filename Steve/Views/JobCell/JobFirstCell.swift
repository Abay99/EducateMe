//
//  JobFirstCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 22/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class JobFirstCell: UITableViewCell {

    // IBOutlets
    @IBOutlet weak var jobTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Custom Method
    func setupJobID(jobID:Int) {
        self.jobTitleLabel.text = "Job Id : \(jobID)"
    }
}
