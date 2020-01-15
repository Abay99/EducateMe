//
//  ResetPasswordConfirmationVC.swift
//  Steve
//
//  Created by Parth Grover on 5/16/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics
class ResetPasswordConfirmationVC: UIViewController {

    
    @IBOutlet weak var topView: TopBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SEGAnalytics.shared().screen(AnalyticsScreens.resetPasswordConfirmationVC)

        // Do any additional setup after loading the view.
        setupNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func setupNavigationBar() {
        self.topView.setHeaderData(title: AppText.resetPasswordConfirmTitle)
        self.topView.delegate = self
    }
    
    
    // MARK: - Action Methods
    @IBAction func signInTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

extension ResetPasswordConfirmationVC: TopBarViewDelegate {
    //MARK: - TopBarViewDelegate
    func didTapLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
}
