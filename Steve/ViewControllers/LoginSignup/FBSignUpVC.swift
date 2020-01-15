//
//  FBSignUpVC.swift
//  Steve
//
//  Created by Parth Grover on 5/17/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics

class FBSignUpVC: UIViewController {

    
    @IBOutlet weak var topView: TopBarView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var fullNameTextField: CustomTextField!
    
    @IBOutlet weak var emailTextField: CustomTextField!
    
    var userFacebookData: UserFacebookData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SEGAnalytics.shared().screen(AnalyticsScreens.facebookSignUpVC)

        // Do any additional setup after loading the view.
        self.topView.setHeaderData(title: AppText.facebookSignUpTitle)
        fullNameTextField.backgroundColor = CustomColor.forgotPasswordTextFieldBackgroundColor
        emailTextField.backgroundColor = CustomColor.forgotPasswordTextFieldBackgroundColor
        if (userFacebookData != nil){
            self.fullNameTextField.text = userFacebookData?.name
            
            if (userFacebookData?.email?.count ?? 0) == 0 {
                self.emailTextField.isUserInteractionEnabled = true
            }
            self.emailTextField.text = userFacebookData?.email
         
            let imageUrl = URL(string: userFacebookData?.profilePicture ?? "")
            self.profileImageView.kf.setImage(with: imageUrl)
        }
        
        let path = UIBezierPath(roundedRect:profileImageView.bounds,
                                byRoundingCorners:[.topRight, .bottomRight],
                                cornerRadii: CGSize(width: 40, height:  40))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        profileImageView.layer.mask = maskLayer
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func signUpWithFacebook() {
        view.showLoader()
        DataManager.shared.socialSignUpWithID(userFacebookData?.accountID ?? "", fbAccessToken: userFacebookData?.fb_accessToken ?? "", email: emailTextField.text ?? "", name: fullNameTextField.text ?? "", imageUrl: userFacebookData?.profilePicture ?? "") { result, success, error, statusCode in
            self.view.hideLoader()
            if success {
                UserDefaults.save(value: true, forKey: AppStatus.isLoginDone)
                // Will Move to Profile or dashboard Screen from here
                if (UserManager.shared.activeUser?.gender) == nil {
                    // Move to profile view
                    let vc = UIStoryboard.navigateToAddProfileVC()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    // Will Move to Profile or dashboard Screen from here
                }
            } else {
                // Show error
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
    
    func checkForValidations() -> Bool {
        if fullNameTextField.text?.trimmed().length == 0 {
            fullNameTextField.showError(with: ValidationMessages.emptyFullName, viewController: self)
            return false
        }else if emailTextField.text?.trimmed().length == 0 {
            emailTextField.showError(with: ValidationMessages.emptyEmailId, viewController: self)
            return false
        } else if emailTextField.text?.trimmed().isValidEmail() == false {
            emailTextField.showError(with: ValidationMessages.invalidEmailId, viewController: self)
            return false
        }
        return true
    }

    
// MARK: - Action
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if (userFacebookData != nil){
            if checkForValidations(){
                view.endEditing(true)
                signUpWithFacebook()
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension FBSignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
