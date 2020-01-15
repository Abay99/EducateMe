//
//  AddWorkHistoryVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 25/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics

class AddWorkHistoryVC: UIViewController {

    // IBOutlets
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameTextField: ProfileTextField!
    @IBOutlet weak var emailTextField: ProfileTextField!
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    // Variables
    var employerView: EmployerListView?
    var isEditActive:Bool = false
    var name:String?
    var email:String?
    var completion:((_ data:[WorkHistories])-> Void)?
    var suggestEmployer:[Employers] = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        SEGAnalytics.shared().screen(AnalyticsScreens.AddWorkHistoryVC)

        self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Method
    private func setupTopView() {
        self.topView.setHeaderData(title: NavTitle.workHistory, rightButtonImage: AppImage.crossButton)
        self.topView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.topView.delegate = self
    }
    
    private func setupUI() {
        self.setupTopView()
        self.containerView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.5)
        self.fillDataIfEdit()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func fillDataIfEdit() {
        if self.isEditActive {
            self.headerLabel.text = AppText.editHeaderText
            self.nameTextField.text = name
            self.emailTextField.text = email
        } else {
            self.headerLabel.text = AppText.addHeaderText
        }
    }
    
    private func validateInputs() -> Bool {
        var isValidInputs = false
        let (isValid, _ , _) = Utilities.validateTextFieldInputs(self.nameTextField)
        if !isValid {
            TopMessage.shared.showMessageWithText(text: AppText.employerNameEmptyFieldMsg, completion: nil)
            return false
        } else {
            isValidInputs = isValid
        }
        
        let (isValidEmail, _ , _) = Utilities.validateTextFieldInputs( self.emailTextField)
        if !isValidEmail {
            TopMessage.shared.showMessageWithText(text: ValidationMessages.emptyEmailId, completion: nil)
            return false
        } else {
            isValidInputs = isValid
        }
        
        if emailTextField.text?.trimmed().isValidEmail() == false {
            TopMessage.shared.showMessageWithText(text: ValidationMessages.invalidEmailId, completion: nil)
            isValidInputs = false
        }
        
        return isValidInputs
    }
    
    // MARK: - IBActions
    @IBAction func saveClicked() {
        self.view.endEditing(true)
        if self.validateInputs() == false {
            return
        }
        self.saveWorkHistory()
    }
}

extension AddWorkHistoryVC: UITextFieldDelegate {
    // MARK: - Textfield Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.removeEmployerView()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " && textField.text == "" {
            return false
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if (textField.text?.count ?? 0) > 2 {
            self.perform(#selector(searchEmployer), with: textField, afterDelay: 1.0)
        }
        
        return true
    }
}

extension AddWorkHistoryVC {
    // MARK: - Web Services
    @objc func searchEmployer(textField:UITextField) {
        let isEmail = (textField == self.emailTextField) ? true : false
        DataManager.shared.searchEmployer(name: isEmail ? "" : textField.text ?? "", email: isEmail ? textField.text ?? "" : "") { (employerData, _, error) in
            DispatchQueue.main.async {
                if error == nil {
                    self.suggestEmployer = employerData ?? []
                    if self.suggestEmployer.count == 0 {
                        self.removeEmployerView()
                    } else {
                        if self.employerView != nil {
                            self.employerView?.loadTableData(datasource: self.suggestEmployer)
                        } else {
                            self.addEmployerView(data: self.suggestEmployer, textField: textField)
                        }
                    }
                }
            }
        }
    }
    
    func saveWorkHistory() {
        self.view.showLoader()
        DataManager.shared.workHistory(name: self.nameTextField.text, email: self.emailTextField.text) { (user, success, error, _) in
            self.view.hideLoader()
            if error == nil {
                if success == true {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.appendUserHistory.value), object: user)
                    self.didTapRightButton(nil);
                }
                else {
                    TopMessage.shared.showMessageWithText(text: user?.workHistoryMsg ?? "", completion: nil)
                }
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
}

extension AddWorkHistoryVC {
    // MARK: - search result list
    func addEmployerView(data:[Employers]?, textField:UITextField) {
        self.employerView = EmployerListView.employerTable()
        self.employerView?.completion = { [unowned self](result) in
            self.nameTextField.text = result.name
            self.emailTextField.text = result.email
            self.view.endEditing(true)
            self.removeEmployerView()
        }
        self.employerView?.loadTableData(datasource: data)
        
        var newFrame = self.employerView!.frame
        newFrame.origin.x = 10
        if self.emailTextField.isFirstResponder {
            //newFrame.origin.y = textField.frame.origin.y - (self.employerView?.frame.height ?? 0 - 00)
             //newFrame.origin.y = textField.frame.origin.y - textField.frame.size.height - emailTextField.frame.size.height - emailTextField.frame.size.height
            newFrame.origin.y = textField.frame.origin.y + textField.frame.size.height
        } else {
            newFrame.origin.y = textField.frame.origin.y + textField.frame.size.height
        }
        //debugPrint(newFrame.origin.y)
        newFrame.size.width = textField.frame.size.width
        self.employerView!.frame = newFrame
        self.employerView?.employerTableView.layoutSubviews()
        self.containerView.addSubview(self.employerView!)
    }
    
    func removeEmployerView() {
        self.employerView?.removeFromSuperview()
        if self.employerView != nil {
            self.employerView = nil
        }
    }
}

extension AddWorkHistoryVC: TopBarViewDelegate {
    // MARK: - TopView Delegate
    func didTapRightButton(_ btn: UIButton?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension AddWorkHistoryVC {
    // MARK: - Keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            debugPrint(self.scrollView.contentSize)
            if self.scrollViewBottomConstraint.constant == 0 {
                self.scrollViewBottomConstraint.constant = keyboardSize.height
                self.scrollView.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.scrollViewBottomConstraint.constant == keyboardSize.height {
                self.scrollViewBottomConstraint.constant -= keyboardSize.height
            }
            debugPrint(self.scrollView.contentSize)
        }
    }
}
