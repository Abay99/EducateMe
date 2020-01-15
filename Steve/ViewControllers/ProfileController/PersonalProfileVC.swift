//
//  PersonalProfileVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 15/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics
class PersonalProfileVC: UIViewController {

    // IBOutlets
    @IBOutlet weak var qualificationView: CustomTextView!
    @IBOutlet weak var experienceView: CustomTextView!
    @IBOutlet weak var biodataView: CustomTextView!
    @IBOutlet weak var youtubeView: CustomTextView!
    @IBOutlet weak var youtubeTextField: ProfileTextField!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeCountLabel: UILabel!
    
    // Variables
    //var profileList:CreateProfile?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        SEGAnalytics.shared().screen(AnalyticsScreens.personalProfileVC)
        self.setAccessebilityOnTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        badgeView.isHidden = true
        if let count = UserManager.shared.getUserUploadedDoc()?.count {
            if count > 0 {
                badgeView.isHidden = false
                badgeCountLabel.text = "\(count)"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Custom Method
    private func setAccessebilityOnTextView() {
        self.qualificationView.textView.accessibilityLabel = self.qualificationView.accessibilityLabel
        self.experienceView.textView.accessibilityLabel = self.experienceView.accessibilityLabel
        self.biodataView.textView.accessibilityLabel = self.biodataView.accessibilityLabel
//        self.youtubeView.textView.accessibilityLabel = self.youtubeView.accessibilityLabel
//        self.youtubeView.textView.keyboardType = .URL
//        self.youtubeView.textView.autocapitalizationType = .none
    }
    
    private func saveData() {
        profileList.qualification = self.qualificationView.textView.text
        profileList.workExperience = self.experienceView.textView.text
        profileList.bio = self.biodataView.textView.text
        profileList.youtubeLink = self.youtubeTextField.text //self.youtubeView.textView.text
    }
    
    // MARK: - IBActions
    @IBAction func nextClicked() {
        self.view.endEditing(true)
        
        let (isValidBio, _, _) = Utilities.validateTextViewInputs(self.biodataView.textView)
        let (isValidYoutube, _, _) = Utilities.validateTextFieldInputs(self.youtubeTextField)
        if isValidYoutube {
            let isValidLink = Utilities.isYoutubeLink(checkString: self.youtubeTextField.text!)
            if !isValidLink {
                TopMessage.shared.showMessageWithText(text: ValidationMessages.validYoutubeLink , completion: nil)
                return
            }
        }
        if isValidBio || isValidYoutube {
//            self.saveData()
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.moveNext.value), object: nil)
        } else {
            TopMessage.shared.showMessageWithText(text: ValidationMessages.bioOrYoutubeRequire , completion: nil)
            return
        }
        let (isValidQua, _, _) = Utilities.validateTextViewInputs( self.qualificationView.textView)
        if !isValidQua {
            TopMessage.shared.showMessageWithText(text: AppText.qualificationEmptyMsg , completion: nil)
            return
        }
        
        let (isValid, _, _) = Utilities.validateTextViewInputs( self.experienceView.textView)
        if !isValid {
            TopMessage.shared.showMessageWithText(text: AppText.workExpEmptyMsg , completion: nil)
            return
        }
        else{
            self.saveData()
            
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.moveNext.value), object: nil)
        }
        
    }
    
    @IBAction func btnUploadIDProof(_ sender: Any) {
        let docVc = UIStoryboard.navigateToDocumentTypeVC()
        self.navigationController?.present(docVc, animated: true) {
            
        }
        //self.navigationController?.pushViewController(docVc, animated: true)
    }
    
}

extension PersonalProfileVC: UITextFieldDelegate {
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
