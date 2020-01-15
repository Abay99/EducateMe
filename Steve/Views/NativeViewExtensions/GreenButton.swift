//
//  GreenButton.swift
//  Steve
//
//  Created by Pardeep Bishnoi on 15/02/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class GreenButton: UIButton {

    // MARK: - Life Cycle Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        doIntialSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doIntialSetup()
    }
}

// MARK: Helpers
extension GreenButton {
    func doIntialSetup() {
        self.backgroundColor = UIColor.green
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
    }
}
