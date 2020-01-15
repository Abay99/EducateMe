//
//  ForgotPasswordVC.swift
//  Steve
//
//  Created by Parth Grover on 5/11/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics

class ForgotPasswordVC: UIViewController {

    
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var emailTextField: CustomTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //SEGAnalytics.shared().track(Analytics.loadedAPpage)
        SEGAnalytics.shared().screen(AnalyticsScreens.forgotPassword)
        
        // Do any additional setup after loading the view.
        setupNavigationBar()
        emailTextField.textpadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        emailTextField.placeholderPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        emailTextField.backgroundColor = CustomColor.forgotPasswordTextFieldBackgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigationBar() {
        self.topView.setHeaderData(title: AppText.forgotPasswordTitle, leftButtonImage: AppImage.backButton)
        self.topView.delegate = self
    }
    
    func checkForValidations() -> Bool {
        if emailTextField.text?.trimmed().length == 0 {
            emailTextField.showError(with: ValidationMessages.emptyEmailId, viewController: self)
            return false
        } else if emailTextField.text?.trimmed().isValidEmail() == false {
            emailTextField.showError(with: ValidationMessages.invalidEmailId, viewController: self)
            return false
        }
        return true
    }
    
    // MARK: - Action Methods
    @IBAction func resetPasswordTapped(_ sender: Any) {
        if checkForValidations() {
            view.endEditing(true)
            forgotPasswordForEmail(email: emailTextField.text!)
        }
    }
}

extension ForgotPasswordVC: TopBarViewDelegate {
    //MARK: - TopBarViewDelegate
    func didTapLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

//API Call
extension ForgotPasswordVC {
    func forgotPasswordForEmail(email:String) {
        view.showLoader()
        DataManager.shared.forgotPasswordWithEmailID(email, completion: { success, message ,error in
            self.view.hideLoader()
            if error == nil {
                let confirmVC = UIStoryboard.navigateToResetPasswordConfirmVC()
                self.navigationController?.pushViewController(confirmVC, animated: true)
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        })
    }
}


// MARK: - UITextFieldDelegate
extension ForgotPasswordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField.isFirstResponder {
             emailTextField.endEditing(true)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn
        range: NSRange, replacementString string: String) -> Bool {
        
        // For restrict user to enter blank value in starting
        if string == "" && range.length == 1 {
            return true
        }
        if string == " " && textField.text == "" {
            return false
        }
        return true
    }
}
