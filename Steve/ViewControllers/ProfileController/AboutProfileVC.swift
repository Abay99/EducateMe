//
//  AboutProfileVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 15/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Analytics

enum Gender:Int {
    case male = 1
    case female = 2
}

class AboutProfileVC: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var aboutScrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet var radioButtonsViews: [UIView]!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!

    // Variables
    var selectedGender:Gender = .female
    var profileImage = UIImage()
    //var profileList = ProfileCreation.shared
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        SEGAnalytics.shared().track(Analytics.loadedAPpage)
//        SEGAnalytics.shared().track(Analytics.loadedAscreen)
        SEGAnalytics.shared().screen(AnalyticsScreens.aboutProfileVC)
        

        self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Custom Methods
    private func setupUI() {
        if let imageUrlString = UserManager.shared.activeUser.imageUrl{
            let imageUrl = URL(string: imageUrlString)
            //self.profileImageView.kf.setImage(with: imageUrl)
            self.profileImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "malePlaceholder"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        else{
            self.profileImageView.image = UIImage.init(named: "malePlaceholder")
        }
        
        self.updateGenderSelection()
        self.profileImageView.superview?.roundSpecificCorner(corners: [.topRight, .bottomRight], cornerRadius: 40)
//        let path = UIBezierPath(roundedRect:profileImageView.bounds,
//                                byRoundingCorners:[.topRight, .bottomRight],
//                                cornerRadii: CGSize(width: 40, height:  40))
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = path.cgPath
//        profileImageView.layer.mask = maskLayer
        if let user = UserManager.shared.activeUser {
            self.nameTextField.text = user.name
        }
    }
    
    private func updateGenderSelection() {
        switch self.selectedGender {
        case .female:
            let imgView = self.radioButtonsViews[0].viewWithTag(5) as! UIImageView
            imgView.image = UIImage(named: AppImage.blueRadio)
        case .male:
            let imgView = self.radioButtonsViews[1].viewWithTag(5) as! UIImageView
            imgView.image = UIImage(named: AppImage.blueRadio)
        }
    }
    
    private func saveData() {
        profileList.name = self.nameTextField.text
        profileList.age = Int(self.ageTextField.text ?? "0")
        profileList.phoneNumber = self.mobileTextField.text
        profileList.gender = self.selectedGender.rawValue
        
        let imgData = UIImageJPEGRepresentation(profileImage, 0.7)
        let base64String = imgData?.base64EncodedString()
        profileList.image = base64String
        
        SEGAnalytics.shared().track(Analytics.onboardingAboutInfo, properties:[AnalyticsPorperties.name:self.nameTextField.text , AnalyticsPorperties.gender:self.selectedGender.rawValue,AnalyticsPorperties.age:profileList.age] )

    }
    
    // MARK: - IBActions
    @IBAction func cameraButtonAction() {
        self.view.endEditing(true)
        self.chooseImageFrom()
    }
  
   
    @IBAction func radioButtonClicked(btn:UIButton) {
        self.selectedGender = ((btn.tag - 100) == 1) ? .female : .male
        for view in radioButtonsViews {
            if view.tag == btn.tag {
                let imageView = view.viewWithTag(5) as! UIImageView
                imageView.image = UIImage(named: AppImage.blueRadio)
            } else {
                let imageView = view.viewWithTag(5) as! UIImageView
                imageView.image = UIImage(named:AppImage.greyRadio)
            }
        }
    }
    
    @IBAction func nextButtonClicked() {
        self.view.endEditing(true)
        
        let (isValid, _, _) = Utilities.validateTextFieldInputs(self.nameTextField)
        if !isValid {
            TopMessage.shared.showMessageWithText(text: AppText.nameEmptyFieldmsg , completion: nil)
            return
        }
        
        let (valid, _, _) = Utilities.validateTextFieldInputs(self.mobileTextField)
        if !valid {
            TopMessage.shared.showMessageWithText(text: AppText.mobileEmptyFieldMsg , completion: nil)
            return
        }
        
        let (isAgeValid, _, _) = Utilities.validateTextFieldInputs(self.ageTextField)
        if isAgeValid {
            if Int(self.ageTextField.text!) ?? 0 < 15 {
                TopMessage.shared.showMessageWithText(text: ValidationMessages.underAge , completion: nil)
                return
            }
        }
        if self.mobileTextField.text!.count < 9 {
            TopMessage.shared.showMessageWithText(text: ValidationMessages.mobileNotValid , completion: nil)
            return
        }

        self.saveData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.moveNext.value), object: nil)
    }
}

extension AboutProfileVC: UITextFieldDelegate {
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
        if textField == self.ageTextField || textField == self.mobileTextField {
            IQKeyboardManager.sharedManager().enableAutoToolbar = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.mobileTextField && string != "" {
            return ((textField.text?.count ?? 0) >= 10) ? false : true
        }
        if textField == self.ageTextField && string != "" {
            return ((textField.text?.count ?? 0) >= 2) ? false : true
        }
        if textField == self.nameTextField && string != "" {
//            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
//            let filtered = string.components(separatedBy: cs).joined(separator: "")
//            return (string == filtered)
            
        }
        if textField == self.nameTextField && string != "" {
            return ((textField.text?.count ?? 0) >= 50) ? false : true
        }
        
        return true
    }
}

extension AboutProfileVC {
    //MARK: - ImagePicker
    func chooseImageFrom() {
        /* Open Action Sheet for Image */
        Utilities.openActionSheetWith(openIn: self) { actionIndex in
            switch actionIndex {
            case 0: // Add photo from gallery
                self.openImageGalleryOrCamera(openGallery: true)
                break
            case 1: // Take a new photo
                self.openImageGalleryOrCamera(openGallery: false)
                break
            default:
                self.openImageGalleryOrCamera(openGallery: true)
                break
            }
        }
    }
    
    override func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        dismiss(animated: true, completion: {
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.profileImageView.image = image
                self.profileImage = image
            }
        })
    }
    
    /* Open Image Gallery or Camera as per user selection */
    func openImageGalleryOrCamera(openGallery: Bool) {
        let picker: UIImagePickerController? = UIImagePickerController()
        picker?.delegate = self
        picker!.sourceType = openGallery ? .photoLibrary : UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker?.allowsEditing = true
        present(picker!, animated: true, completion: nil)
    }
}
