//
//  VerifyEmailVC.swift
//  Steve
//
//  Created by Parth Grover on 5/11/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics
class VerifyEmailVC: UIViewController {

    
    @IBOutlet weak var topView: TopBarView!
    var emailForVerification : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SEGAnalytics.shared().track(Analytics.loadedAscreen)
        SEGAnalytics.shared().screen(AnalyticsScreens.VerifyEmailVC)

        // Do any additional setup after loading the view.
        setupNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigationBar() {
        self.topView.setHeaderData(title: AppText.verifyEmailTitle, leftButtonImage: AppImage.backButton)
        self.topView.delegate = self
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func proceedButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    
    @IBAction func resendEmailTapped(_ sender: Any) {
        view.showLoader()
        DataManager.shared.resendVerificationEmail(emailForVerification ?? "", completion: { success, message ,error in
                self.view.hideLoader()
                if error == nil {
                    TopMessage.shared.showMessageWithText(text: message!, completion: nil)
                } else {
                    TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
                }
        })
    }
}


extension VerifyEmailVC: TopBarViewDelegate {
    //MARK: - TopBarViewDelegate
    func didTapLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
}
