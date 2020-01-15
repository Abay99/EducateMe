//
//  ConflictView.swift
//  Steve
//
//  Created by Sudhir Kumar on 25/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

enum ConfilctAction {
    case moreJobs
    case conflict
}

class ConflictView: UIView {
    
    // Variables
    var completion:((ConfilctAction)-> Void)?
    
    // MARK: - Initialization
    class func createConflictView() -> ConflictView {
        let view = Bundle.main.loadNibNamed("ConflictView", owner: self, options: nil)?[0] as! ConflictView
        return view
    }
    
    // Mark: - IBActions
    @IBAction func buttonActions(btn:UIButton) {
        let action:ConfilctAction = (btn.tag == 1) ? .moreJobs : .conflict
        if self.completion != nil {
            self.completion!(action)
        }
    }
}
