//
//  AccountVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 08/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Analytics

class AccountVC: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: ProfileTextField!
    @IBOutlet weak var bsbTextField: ProfileTextField!
    @IBOutlet weak var accountTextField: ProfileTextField!
    @IBOutlet weak var doneButton: UIButton!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        SEGAnalytics.shared().track(Analytics.loadedAPpage)
//        SEGAnalytics.shared().track(Analytics.loadedAscreen)
        SEGAnalytics.shared().screen(AnalyticsScreens.AccountVC)

        self.setupUI()
        nameTextField.delegate = self
        bsbTextField.delegate = self
        accountTextField.delegate = self
        showMyProfile()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Custom Method
    private func setupUI() {
        self.topView.setHeaderData(title: NavTitle.payment, leftButtonImage: AppImage.backButton, rightButtonImage: "AppImage.editIcon")
        
        self.topView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.topView.delegate = self
    }
    
    private func setupData() {
        
    }
    
    private func enableDisableTextField(status:Bool) {
        nameTextField.isEnabled = status
        accountTextField.isEnabled = status
        bsbTextField.isEnabled = status
    }
    
    
    
    private func validateCustomTextView() -> Bool {
        var isBSBSValid = false
        let (isNameValid, _, _) = Utilities.validateTextFieldInputs(self.nameTextField)
        if !isNameValid {
            TopMessage.shared.showMessageWithText(text: AppText.nameEmptyFieldmsg , completion: nil)
            return false
        }
        
        if self.bsbTextField.text?.trimmed().count ?? 0 < 6 {
            TopMessage.shared.showMessageWithText(text: AppText.bsbMinFieldMsg , completion: nil)
            return false
        }
        
        let (isBSBValid, _, _) = Utilities.validateTextFieldInputs(self.bsbTextField)
        if !isBSBValid {
            TopMessage.shared.showMessageWithText(text: AppText.bsbEmptyFieldmsg , completion: nil)
            return false
        }
        if self.bsbTextField.text?.trimmed().contains("-") == true {
            //var isBSBSValid = true
            if Utilities.isBSBNumber(checkString: self.bsbTextField.text?.trimmed() ?? "") == true {
                //TopMessage.shared.showMessageWithText(text: AppText.invalidBSBFieldMsg , completion: nil)
                isBSBSValid = true
            }
            if Utilities.isBSBNumberSecond(checkString: self.bsbTextField.text?.trimmed() ?? "") == true {
                //TopMessage.shared.showMessageWithText(text: AppText.invalidBSBFieldMsg , completion: nil)
                isBSBSValid = true
            }
            if isBSBSValid ==  false {
                TopMessage.shared.showMessageWithText(text: AppText.invalidBSBFieldMsg , completion: nil)
                return isBSBSValid;
            }
        }
        
        if self.accountTextField.text?.trimmed().count ?? 0 < 6 {
            TopMessage.shared.showMessageWithText(text: AppText.accountMinFieldMsg , completion: nil)
            return false
        }
        let (isAccountValid, _, _) = Utilities.validateTextFieldInputs(self.accountTextField)
        if !isAccountValid {
            TopMessage.shared.showMessageWithText(text: AppText.accountEmptyFieldMsg , completion: nil)
            return false
        }
        return true
    }
    
    // MARK : - IBAction 
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if validateCustomTextView() == true {
            updateAccount();
        }
    }
    
}

extension AccountVC: UITextFieldDelegate {
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.bsbTextField || textField == self.accountTextField {
            IQKeyboardManager.sharedManager().enableAutoToolbar = true
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        if (accountTextField.text?.trimmed().count) ?? 0 > 0 && bsbTextField.text?.trimmed().count ?? 0 > 0 && nameTextField.text?.trimmed().count ?? 0 > 0 {
            doneButton.backgroundColor = CustomColor.preferenceSelectionColor
            doneButton.isEnabled = true
        }
        else {
            doneButton.backgroundColor = CustomColor.buttonDisableColor
            doneButton.isEnabled = false
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.accountTextField && string != "" {
            if  Int(string) == nil  &&  string != "-" {
                return false;
            }
//            else if string != "-" {
//                return false
//            }
            else {
               return ((textField.text?.count ?? 0) >= 18) ? false : true
            }
        }
        
         if textField == self.bsbTextField && string != "" {
            return ((textField.text?.count ?? 0) >= 7) ? false : true
        }
        return true
    }
}

extension AccountVC:TopBarViewDelegate {
    func didTapLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapRightButton(_ btn: UIButton?) {
        enableDisableTextField(status: true)
        nameTextField.becomeFirstResponder()
    }
}

// MARK : - WebServices
extension AccountVC {
    func  updateAccount()  {
        self.view.showLoader()
        
        SEGAnalytics.shared().track(Analytics.onboardingPaymentDetailsAdded)
        
        DataManager.shared.updatePaymentInfo( accountHolderName: (nameTextField.text?.trimmed())!, accountNumber: (accountTextField.text?.trimmed())!, bsb: bsbTextField.text!) { (status, message, error) in
            self.view.hideLoader()
            if error == nil {
                UserManager.shared.activeUser?.accountNo = self.accountTextField.text
                UserManager.shared.activeUser?.accountTitle = self.nameTextField.text
                UserManager.shared.activeUser?.accRouting = self.bsbTextField.text
                TopMessage.shared.showMessageWithText(text: message ?? "", completion: nil)
                self.didTapLeftButton()
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
    
    private func showMyProfile() {
        self.view.showLoader()
        DataManager.shared.showProfile { (userData, _, error, status) in
            self.view.hideLoader()
            if error == nil {
                if let _ = userData?.accountNo {
                    self.nameTextField.text  = userData?.accountTitle;
                    self.accountTextField.text = userData?.accountNo;
                    self.bsbTextField.text = userData?.accRouting;
                    self.topView.setHeaderData(title: NavTitle.payment, leftButtonImage: AppImage.backButton, rightButtonImage: AppImage.editIcon)
                    self.enableDisableTextField(status: false)
                }
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
}
