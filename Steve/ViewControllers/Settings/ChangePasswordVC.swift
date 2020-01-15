//
//  ChangePasswordVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 08/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics

class ChangePasswordVC: UIViewController {

    // IBOutlets
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var oldPasswordTextField: ProfileTextField!
    @IBOutlet weak var newPasswordTextField: ProfileTextField!
    @IBOutlet weak var confirmPasswordTextField: ProfileTextField!
    @IBOutlet weak var firstShowButton: UIButton!
    @IBOutlet weak var secondShowButton: UIButton!
    @IBOutlet weak var thirdShowButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var firstShowWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondShowWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdShowWidthConstraint: NSLayoutConstraint!
    
    // Variable
    var isDoneEnable:Bool {
        //return self.firstShowWidthConstraint.constant > 0 && self.secondShowWidthConstraint.constant > 0 && self.thirdShowWidthConstraint.constant > 0
        return (self.oldPasswordTextField?.text?.count ?? 0) > 0 && (self.newPasswordTextField?.text?.count ?? 0) > 0 && (self.confirmPasswordTextField?.text?.count ?? 0) > 0
    }
    
    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
//        SEGAnalytics.shared().track(Analytics.loadedAPpage)
//        SEGAnalytics.shared().track(Analytics.loadedAscreen)
        SEGAnalytics.shared().screen(AnalyticsScreens.ChangePasswordVC)

        self.setupTopView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Custom Method
    private func setupTopView() {
        self.topView.setHeaderData(title: NavTitle.changePassword, leftButtonImage: AppImage.backButton)
        self.topView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.topView.delegate = self
        self.firstShowWidthConstraint.constant = 60
        self.secondShowWidthConstraint.constant = 60
        self.thirdShowWidthConstraint.constant = 60
        self.doneButton.isEnabled = true
        self.doneButton.backgroundColor = CustomColor.preferenceSelectionColor
        self.view.layoutIfNeeded()
    }
    
    private func toggleDoneEnable() {
        if self.isDoneEnable {
            if self.doneButton.isEnabled {
                return
            }
            self.doneButton.isEnabled = true
            self.doneButton.backgroundColor = CustomColor.preferenceSelectionColor
        } else {
            if !self.doneButton.isEnabled {
                return
            }
            self.doneButton.isEnabled = false
            self.doneButton.backgroundColor = CustomColor.buttonDisableColor
        }
    }
    
    // MARK: - IBActions
    @IBAction func showPasswordAction(sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
        
        if sender.tag == 100 {
            self.oldPasswordTextField.toggleSecureText()
        } else if sender.tag == 101 {
            self.newPasswordTextField.toggleSecureText()
        } else {
            self.confirmPasswordTextField.toggleSecureText()
        }
    }
    
    @IBAction func doneButtonAction() {
        let (isValid, _, _) = Utilities.validateTextFieldInputs(self.oldPasswordTextField, self.newPasswordTextField, self.confirmPasswordTextField)
        if !isValid {
            TopMessage.shared.showMessageWithText(text: ValidationMessages.AllFieldMandatory, completion: nil)
            return
        }
        
        if (self.newPasswordTextField.text?.trimmed().length ?? 0) < 8 {
            TopMessage.shared.showMessageWithText(text: ValidationMessages.invalidPassword, completion: nil)
            return
        }
        
        if self.newPasswordTextField.text == self.confirmPasswordTextField.text {
            if self.newPasswordTextField.text != self.oldPasswordTextField.text {
                self.changeMyPassword()
            } else {
                TopMessage.shared.showMessageWithText(text: ValidationMessages.oldPasswordValidation, completion: nil)
                return
            }
        } else {
            TopMessage.shared.showMessageWithText(text: ValidationMessages.confirmPassword, completion: nil)
            return
        }
    }
}

extension ChangePasswordVC: UITextFieldDelegate {
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string == " " {
            return false
        }
        return true
    }
}

extension ChangePasswordVC {
    // MARK: - Web Services
    private func changeMyPassword() {
        self.view.showLoader()
        DataManager.shared.changePassword(self.oldPasswordTextField.text!, self.newPasswordTextField.text!) { (_, message, error) in
            self.view.hideLoader()
            if error == nil {
                TopMessage.shared.showMessageWithText(text: message ?? "", completion: nil)
                self.didTapLeftButton()
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
}

extension ChangePasswordVC: TopBarViewDelegate {
    // MARK: - TopView Delegate
    func didTapLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
}
