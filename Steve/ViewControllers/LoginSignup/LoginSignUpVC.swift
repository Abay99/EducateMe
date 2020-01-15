//
//  LoginSignUpVC.swift
//  Steve
//
//  Created by Parth Grover on 5/9/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import Analytics
let MaxCharactersLimit: Int = 20


class LoginSignUpVC: UIViewController {
    
    // MARK: - Properties
    enum CurrentView: Int {
        case signUpView
        case signInView
    }
    
    var currentSelectedView: Int = 0
    var userFacebookData: UserFacebookData?
    var showPassword : Bool!
    var isFromJobDetail:Bool = false
    var isFromFindJobVC:Bool = false
    
    
    @IBOutlet weak var signUpViewIndicator: UILabel!
    
    @IBOutlet weak var signInViewIndicator: UILabel!
    
    @IBOutlet weak var facebookButton: UIButton!
    
    @IBOutlet weak var emailTextField: CustomTextField!
    
    @IBOutlet weak var passwordTextField: CustomTextField!
    
    @IBOutlet weak var signUpTypeBottomView: UIView!
    
    @IBOutlet weak var signInTypeBottomView: UIView!
    
    @IBOutlet weak var continueAsGuestButton: UIButton!
    
    @IBOutlet weak var showPsswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
       // SEGAnalytics.shared().track(Analytics.loadedAscreen)
        doInitialSetup()
        showPassword = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func signUpViewTapped(_ sender: Any) {
        showCurrentView(tag: CurrentView.signUpView.rawValue)
        SEGAnalytics.shared().screen(AnalyticsScreens.LoginVC)
        self.clearFilledDetails()
    }
    
    @IBAction func signInViewTapped(_ sender: Any) {
        showCurrentView(tag: CurrentView.signInView.rawValue)
        self.clearFilledDetails()
        SEGAnalytics.shared().screen(AnalyticsScreens.SignUpVC)

    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        view.endEditing(true)
        if userFacebookData != nil {
            signInWithFacebook()
        } else {
            checkIfFacebookIdExistsAndDoLogin()
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        if checkForValidations() {
            view.endEditing(true)
            registerWithEmail()
        }
    }
    
    @IBAction func termsConditionTapped(_ sender: Any) {
        let termsVC = UIStoryboard.navigateToTermsAndPolicyVC()
        termsVC.isViewTypePolicy = false
        self.navigationController?.pushViewController(termsVC, animated: true)
    }
    
    @IBAction func privacyPolicyTapped(_ sender: Any) {
        let termsVC = UIStoryboard.navigateToTermsAndPolicyVC()
        termsVC.isViewTypePolicy = true
        self.navigationController?.pushViewController(termsVC, animated: true)
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        if checkForValidations() {
            view.endEditing(true)
            loginWithEmail()
        }
    }
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let forgotPasswordVC = UIStoryboard.navigateToForgotPasswordVC()
        self.navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
    @IBAction func continueWithoutSignUp(_ sender: Any) {
        //TopMessage.shared.showMessageWithText(text: "Coming Soon!", completion: nil)
        kAppDelegate.openDashboard()
    }
    
    @IBAction func showPassword(_ sender: Any) {
        if(showPassword == false) {
            passwordTextField.isSecureTextEntry = false
            showPassword = true
            showPsswordButton.setTitle("Hide", for: .normal)
        } else {
            passwordTextField.isSecureTextEntry = true
            showPassword = false
            showPsswordButton.setTitle("Show", for: .normal)
        }
    }
}

// MARK: - Helpers
extension LoginSignUpVC {
    func doInitialSetup() {
        showCurrentView(tag: currentSelectedView)
        //        emailTextField.text = "dev1@yopmail.com"
        //        passwordTextField.text = "11111111"
    }
    
    func showCurrentView(tag: Int) {
        switch tag {
        case CurrentView.signInView.rawValue :
            signInViewIndicator.isHidden = false
            signInTypeBottomView.isHidden = false
            signUpViewIndicator.isHidden = true
            signUpTypeBottomView.isHidden = true
            facebookButton.setTitle("SIGN IN WITH FACEBOOK", for: .normal)
            continueAsGuestButton.isHidden = true
            currentSelectedView = tag
            break
        case CurrentView.signUpView.rawValue :
            signInViewIndicator.isHidden = true
            signInTypeBottomView.isHidden = true
            signUpViewIndicator.isHidden = false
            signUpTypeBottomView.isHidden = false
            facebookButton.setTitle("SIGN UP WITH FACEBOOK", for: .normal)
            continueAsGuestButton.isHidden = false
            currentSelectedView = tag
            break
        default:
            break
        }
    }
    
    func checkForValidations() -> Bool {
        if emailTextField.text?.trimmed().length == 0 {
            emailTextField.showError(with: ValidationMessages.emptyEmailId, viewController: self)
            return false
        } else if emailTextField.text?.trimmed().isValidEmail() == false {
            emailTextField.showError(with: ValidationMessages.invalidEmailId, viewController: self)
            return false
        } else if passwordTextField.text?.trimmed().length == 0 {
            passwordTextField.showError(with: ValidationMessages.emptyPassword, viewController: self)
            return false
        } else if passwordTextField.text?.trimmed().length ?? 0 < 8 {
            passwordTextField.showError(with: ValidationMessages.invalidPassword, viewController: self)
            return false
        }
        return true
    }
    
    func registerWithEmail() {
        view.showLoader()
        DataManager.shared.registerWithEmail(emailTextField.text?.trimmed() ?? "", password: passwordTextField.text?.trimmed() ?? "", completion: { result, success, error, statusCode in
            self.view.hideLoader()
            if error == nil {
                self.showCurrentView(tag: CurrentView.signInView.rawValue)
                let emailVerifyVC = UIStoryboard.navigateToVerifyEmailVC()
                emailVerifyVC.emailForVerification = self.emailTextField.text?.trimmed()
                //self.clearFilledDetails()
                self.passwordTextField.text = ""
                UserManager.shared.saveRegisteredEmail(emailId: self.emailTextField.text?.trimmed() ?? "");
                self.navigationController?.pushViewController(emailVerifyVC, animated: true)
            } else {
                // Show Error
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        })
    }
    
    func loginWithEmail() {
        
        let userCategories = SelectedCategories(userId: 5, category: "Dev", categoryId: 4, parentCategoryName: "Eng", parentCategoryId: 3)
        let doc = Doc(id: 2, documentName: "Typing Certificate", createdAt: "12-12-1999", mediaType: 1, imageData: nil, resourceId: "23", image: "https://wallpapercave.com/wp/jm6KoJF.jpg", imageUrl: "https://wallpapercave.com/wp/jm6KoJF.jpg", docType: 1)
        
        let user = User(email: "nanu@gmail.com", id: 11, facebookId: "nanufacebooc@gmail.com", name: "Nanu", gender: 1, isVerified: 1, updatedAt: "12-12-1999", userToken: "token", userType: 1, image: "https://wallpapercave.com/wp/jm6KoJF.jpg", imageUrl: "https://wallpapercave.com/wp/jm6KoJF.jpg", phoneNumber: "9876543210", averageRating: 2.5, rating: 5.0, isActive: 1, isProfileComplete: 1, address: "New Delhi, Delhi, India", isFacebookUser: 1, longitude: 17.92733, latitude: 11.83736, stripeCustomerId: "cuasdId", defaultRadius: 6, qualification: "M.C.A", workExperience: "5 Yrs", youtubeLink: "https://www.youtube.com/watch?v=3YhQV3aQmb4", userCategories: [userCategories], userWorkHistory: nil, isAvailable: 1, age: 30, bio: "Hi I am Nanu work as a developer", website: "www.google.com", accountNo: "12305968", accountTitle: "Account Title", accRouting: "3.4", workHistoryMsg: "hello this is my work history msg", userDocuments: [doc])
        
        UserManager.shared.activeUser = user
        UserManager.shared.accessToken = "113131313131313"
        
        view.showLoader()
        DataManager.shared.loginWithEmail(emailTextField.text?.trimmed() ?? "", password: passwordTextField.text?.trimmed() ?? "") { result, success , error, statusCode  in
            self.view.hideLoader()
            //if error == nil {
                SEGAnalytics.shared().track(Analytics.loginCompleted)
                UserDefaults.save(value: true, forKey: AppStatus.isLoginDone)
                self.clearFilledDetails()
                if (UserManager.shared.activeUser?.isProfileComplete == 0) {
                    // Move to profile view
                    let vc = UIStoryboard.navigateToAddProfileVC()
                    vc.isFromJobDetail = self.isFromJobDetail
                    vc.isFromFindJobVC = self.isFromFindJobVC
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    // Will Move to Profile or dashboard Screen from here
                    let name = UserManager.shared.activeUser.name
                    let email = UserManager.shared.activeUser.email
                    SEGAnalytics.shared().identify("a user's id", traits: [AnalyticsPorperties.email : email , AnalyticsPorperties.name : name ?? ""])
                    self.moveToAppropriateVC()
                }
                
           // } else {
                // Show error
               // TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
           // }
        }
    }
    
    func moveToAppropriateVC() {
                 if self.isFromFindJobVC {
            // Move To Find JobVC
            
            self.navigationController?.popToRootViewController(animated: true)
        } else if self.isFromJobDetail {
            for vc in (self.navigationController?.viewControllers ?? [UIViewController()]) {
                if vc is JobDetailVC {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
        } else {
            kAppDelegate.openDashboard()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.refreshDataOnLogin.value), object: nil)

    }
    
    func checkIfFacebookIdExistsAndDoLogin() {
        view.showLoader()
        APFacebookManager.sharedManager().login { userDetails, error in
            self.view.hideLoader()
            if error == nil && userDetails != nil {
                // Decode retrived data with JSONDecoder
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: userDetails ?? "", options: .prettyPrinted)
                    self.userFacebookData = try JSONDecoder().decode(UserFacebookData.self, from: jsonData)
                    self.signInWithFacebook()
                } catch {
                    // Show Error
                    TopMessage.shared.showMessageWithText(text: "Facebook Error" , completion: nil)
                }
            }
        }
    }
    
    func signInWithFacebook() {
        view.showLoader()
        DataManager.shared.socialLoginWithID(userFacebookData?.accountID ?? "", fbAccessToken: userFacebookData?.fb_accessToken ?? "" ){ result, success, error, statusCode in
            self.view.hideLoader()
            if success {
                UserDefaults.save(value: true, forKey: AppStatus.isLoginDone)
                if (UserManager.shared.activeUser?.isProfileComplete == 0) {
                    // Move to profile view
                    let vc = UIStoryboard.navigateToAddProfileVC()
                    vc.isFromJobDetail = self.isFromJobDetail
                    vc.isFromFindJobVC = self.isFromFindJobVC
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    // Will Move to Profile or dashboard Screen from here
                    self.moveToAppropriateVC()
                }
            } else {
                // Show error
                if statusCode == 103 {
                    // User is not registered go to FB Sign Up page with data
                    let fbSignUpVC = UIStoryboard.navigateToFBSignUpVC()
                    fbSignUpVC.userFacebookData = self.userFacebookData
                    self.navigationController?.pushViewController(fbSignUpVC, animated: true)
                }
                else{
                    TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
                }
            }
        }
    }
    
    
    
    
    func clearFilledDetails() {
        emailTextField.text = ""
        passwordTextField.text = ""
        if let email = UserManager.shared.getRegisteredEmail() {
            emailTextField.text = email;
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension LoginSignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField.isFirstResponder {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder {
            passwordTextField.endEditing(true)
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
        
        if (textField == self.passwordTextField){
            let currentCharacterCount = textField.text?.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            return newLength <= MaxCharactersLimit
        }
        return true
    }
}
