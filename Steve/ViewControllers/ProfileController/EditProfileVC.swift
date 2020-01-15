//
//  EditProfileVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 04/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Analytics

class EditProfileVC: UIViewController {

    // IBOutlets
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: ProfileTextField!
    @IBOutlet weak var mobileTextField: ProfileTextField!
    @IBOutlet weak var emailTextField: ProfileTextField!
    @IBOutlet weak var ageTextField: ProfileTextField!
    @IBOutlet var radioButtonsViews: [UIView]!
    @IBOutlet weak var qualificationView: CustomTextView!
    @IBOutlet weak var experienceView: CustomTextView!
    @IBOutlet weak var biodataView: CustomTextView!
    @IBOutlet weak var youtubeTextField: ProfileTextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var distanceSlider: CustomSlider!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeCount: UILabel!
    
    // Variables
    var selectedGender:Gender = .female
    var userLatitude = "0.0"
    var userLongitude = "0.0"
    var userAddress:String = ""
    var user:User?
    
    private var profileData = CreateProfile()
    private var selectedIds:[Int] = []
    private var isImageModify = false
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        SEGAnalytics.shared().screen(AnalyticsScreens.EditProfileVC)
        self.setupUI()
        self.setupData()
        //saveData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Custom Method
    
    
    
    private func setupTopView() {
        self.topView.setHeaderData(title: NavTitle.myProfile, leftButtonImage: AppImage.backButton)
        self.topView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.topView.delegate = self
    }
    
    private func setupUI() {
        self.setupTopView()
        self.profileImageView.superview?.roundSpecificCorner(corners: [.topRight, .bottomRight], cornerRadius: 40)
        //self.updateGenderSelection()
        self.setAccessebilityOnTextView()
        self.setupSliderAndAddress()
        self.profileImageView.kf.indicatorType = .activity
    }
    
    private func setupData() {
        self.profileImageView.kf.setImage(with: URL(string:self.user?.imageUrl ?? ""), placeholder: UIImage(named: AppImage.placehoderRounded), options: nil, progressBlock: nil, completionHandler: nil)
        self.selectedGender = ((self.user?.gender ?? 1) == 1) ? .male : .female
        self.updateGenderSelection()
        if let category = self.user?.userCategories {
            self.selectedIds = category.map {$0.categoryId!}
        }
        self.nameTextField.text = self.user?.name ?? ""
        //self.emailTextField.text = self.user?.email ?? ""
        self.mobileTextField.text = self.user?.phoneNumber ?? ""
        self.ageTextField.text = "\(((self.user?.age ?? 0 > 0) ? "\(self.user!.age!)" : ""))"
        self.qualificationView.customText = self.user?.qualification ?? ""
        self.experienceView.customText = self.user?.workExperience ?? ""
        self.biodataView.customText = self.user?.bio ?? ""
        self.youtubeTextField.text = self.user?.youtubeLink ?? ""
        self.addressTextField.text = self.user?.address ?? ""
        self.userLatitude = "\(self.user?.latitude ?? 0)"
        self.userLongitude = "\(self.user?.longitude ?? 0)"
        self.distanceLabel.text = "\(self.user?.defaultRadius ?? 50)km"
        self.distanceSlider.value = Float(self.user?.defaultRadius ?? 50)
        badgeView.isHidden = true
        if user?.userDocuments?.count ?? 0 > 0 {
            badgeView.isHidden = false
            if let count = user?.userDocuments?.count {
                badgeCount.text = "\(count)"
            }
        }
    }
    
    private func setAccessebilityOnTextView() {
        self.qualificationView.textView.accessibilityLabel = self.qualificationView.accessibilityLabel
        self.experienceView.textView.accessibilityLabel = self.experienceView.accessibilityLabel
        self.biodataView.textView.accessibilityLabel = self.biodataView.accessibilityLabel
    }
    
    private func updateGenderSelection() {
        switch self.selectedGender {
        case .female:
            let imgView = (self.radioButtonsViews[0].viewWithTag(5) as? UIImageView) ?? UIImageView.init()
            imgView.image = UIImage(named: AppImage.blueRadio)
        case .male:
            let imgView = (self.radioButtonsViews[1].viewWithTag(5) as? UIImageView) ?? UIImageView.init()
            imgView.image = UIImage(named: AppImage.blueRadio)
        }
    }
    
    private func setupSliderAndAddress() {
        let thumbImage = UIImage(named: AppImage.sliderThumb)
        self.distanceSlider.setThumbImage(thumbImage, for: .normal)
        self.distanceSlider.setThumbImage(thumbImage, for: .disabled)
        self.distanceSlider.setThumbImage(thumbImage, for: .highlighted)
        self.distanceSlider.tintColor = CustomColor.preferenceSelectionColor
        self.distanceSlider.maximumTrackTintColor = .white
        self.distanceSlider.value = 50.0
        self.distanceLabel.text = "\(Int(self.distanceSlider.value))km"
        
        let leftImageView = UIView(frame: CGRect(x: 0, y: 6, width: 26, height: 28))
        let imgView = UIImageView(frame: CGRect(x: 7.5, y: 7, width: 11, height: 14) )
        imgView.image = UIImage(named: AppImage.pinIcon)
        imgView.contentMode = .scaleAspectFit
        leftImageView.addSubview(imgView)
        self.addressTextField.leftView = leftImageView
        self.addressTextField.leftViewMode = .always
    }
    
    private func createModelToSave() {
        if self.isImageModify {
            let imgData = UIImageJPEGRepresentation(self.profileImageView.image ?? UIImage(), 0.7)
            let base64String = imgData?.base64EncodedString()
            self.profileData.image = base64String
        } else {
            self.profileData.image = self.user?.imageUrl ?? ""
        }
        self.profileData.name = self.nameTextField.text
        self.profileData.age = Int(self.ageTextField.text ?? "1")
        self.profileData.phoneNumber = self.mobileTextField.text
        self.profileData.gender = self.selectedGender.rawValue
        self.profileData.qualification = self.qualificationView.textView.text
        self.profileData.workExperience = self.experienceView.textView.text
        self.profileData.bio = self.biodataView.textView.text
        self.profileData.youtubeLink = self.youtubeTextField.text ?? ""
        self.profileData.category = self.selectedIds
        self.profileData.address = self.addressTextField.text ?? ""
        self.profileData.latitude = self.userLatitude
        self.profileData.longitude = self.userLongitude
        self.profileData.radius = Int(self.distanceSlider.value)
    }
    
    private func validateTextFields() -> Bool {
        self.view.endEditing(true)
        let validTextField = self.validateProfileTextFields()
        let validTextView = self.validateCustomTextView()
        if self.selectedIds.count == 0 {
            TopMessage.shared.showMessageWithText(text: ValidationMessages.categoryMessage, completion: nil)
            return false
        }
        if !validTextField || !validTextView {
            return false
        }
        return true
    }
    
    
    // MARK: - Validations
    private func validateProfileTextFields() -> Bool {
        let (isValid, _, _) = Utilities.validateTextFieldInputs(self.nameTextField)
        if !isValid {
            TopMessage.shared.showMessageWithText(text: AppText.nameEmptyFieldmsg , completion: nil)
            return false
        }
        
        let (valid, _, _) = Utilities.validateTextFieldInputs(self.mobileTextField)
        if !valid {
            TopMessage.shared.showMessageWithText(text: AppText.mobileEmptyFieldMsg , completion: nil)
            return false
        }
        
        let (isAgeValid, _, _) = Utilities.validateTextFieldInputs(self.ageTextField)
        if isAgeValid {
            if Int(self.ageTextField.text!) ?? 0 < 1 {
                TopMessage.shared.showMessageWithText(text: ValidationMessages.underAge , completion: nil)
                return false
            }
        }
        if self.mobileTextField.text!.count < 9 {
            TopMessage.shared.showMessageWithText(text: ValidationMessages.mobileNotValid , completion: nil)
            return false
        }
        return true
    }
    
    
    private func validateCustomTextView() -> Bool {
        
        let (isValidBio, _, _) = Utilities.validateTextViewInputs(self.biodataView.textView)
        let (isValidYoutube, _, _) = Utilities.validateTextFieldInputs(self.youtubeTextField)
        if isValidYoutube {
            let isValidLink = Utilities.isYoutubeLink(checkString: self.youtubeTextField.text!)
            if !isValidLink {
                TopMessage.shared.showMessageWithText(text: ValidationMessages.validYoutubeLink , completion: nil)
                return false
            }
        }
        
        if isValidBio || isValidYoutube {
            //
        } else {
            TopMessage.shared.showMessageWithText(text: ValidationMessages.bioOrYoutubeRequire , completion: nil)
            return false
        }
        
        let (isValidQua, _, _) = Utilities.validateTextViewInputs( self.qualificationView.textView)
        if !isValidQua {
            TopMessage.shared.showMessageWithText(text: AppText.qualificationEmptyMsg , completion: nil)
            return false
        }
        
        let (isValid, _, _) = Utilities.validateTextViewInputs( self.experienceView.textView)
        if !isValid {
            TopMessage.shared.showMessageWithText(text: AppText.workExpEmptyMsg , completion: nil)
            return false
        }
       
        return true
    }
    
    // MARK: - IBActions
    @IBAction func cameraButtonAction() {
        self.view.endEditing(true)
        self.chooseImageFrom()
    }
    
    @IBAction func locationButtonTapped() {
        let vc = UIStoryboard.navigateToMapVC()
        vc.lat = Double(self.userLatitude)!
        vc.lng = Double(self.userLongitude)!
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func viewYourDocButtonTap(_ sender: Any) {
        let docVc = UIStoryboard.navigateToDocumentTypeVC()
        docVc.isViewOnly = true;
        docVc.user = self.user
        docVc.documentHandlerSetup { (status,info)   in
            
            if let index = self.user?.userDocuments?.indexOf({$0.docType == info?.id}) {
                self.user?.userDocuments?.remove(at: index);
            }
            if let params = UserManager.shared.getUserUploadedDoc() {
                if params.count > 0 {
                    self.badgeView.isHidden = false
                    self.badgeCount.text = "\(params.count)";
                    if let index = self.user?.userDocuments?.indexOf({$0.id == info?.id}) {
                        self.user?.userDocuments?.remove(at: index);
                    }
                    //self.user?.userDocuments?.remove(at: index)
                }
            }
        }
        self.navigationController?.present(docVc, animated: true) {
        }
    }
    @IBAction func sliderValueChanged() {
        self.distanceSlider.value = Float(roundf(self.distanceSlider.value / 5) * 5)
        self.distanceLabel.text = "\(Int(self.distanceSlider.value))km"
    }
    
    @IBAction func radioButtonClicked(btn:UIButton) {
        self.selectedGender = ((btn.tag - 100) == 1) ? .female : .male
        for view in radioButtonsViews {
            if view.tag == btn.tag {
                let imageView = (view.viewWithTag(5) as? UIImageView) ?? UIImageView.init()
                imageView.image = UIImage(named: AppImage.blueRadio)
            } else {
                let imageView = (view.viewWithTag(5) as? UIImageView) ?? UIImageView.init()
                imageView.image = UIImage(named:AppImage.greyRadio)
            }
        }
    }
    
    @IBAction func editCategoryClicked() {
        let vc = UIStoryboard.navigateToCategoryVC()
//        if let category = self.user?.userCategories {
//            self.selectedIds = category.map {$0.categoryId!}
//        }
        vc.selectedIds = self.selectedIds
        vc.complition = { [weak self] (ids) in
            self?.selectedIds = ids
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func saveClicked() {
        if self.validateTextFields() {
            self.createModelToSave()
            self.updateUserProfile()
        }
    }
}

extension EditProfileVC:TopBarViewDelegate {
    // MARK: - Top View Delegate
    func didTapLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension EditProfileVC {
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
        self.isImageModify = true
        dismiss(animated: true, completion: {
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.profileImageView.image = image
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

extension EditProfileVC: UITextFieldDelegate {
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.ageTextField  || textField == self.mobileTextField {
            IQKeyboardManager.sharedManager().enableAutoToolbar = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == self.mobileTextField && string != "" {
//            return ((textField.text?.count ?? 0) >= 10) ? false : true
//        }
        if textField == self.ageTextField && string != "" {
            return ((textField.text?.count ?? 0) >= 2) ? false : true
        }
        if textField == self.mobileTextField && string != "" {
            return ((textField.text?.count ?? 0) >= 10) ? false : true
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

extension EditProfileVC: UITextViewDelegate {
    // MARK: - TextView Delegate
}

extension EditProfileVC: MapVCDelegate {
    // MARK: - MapVC Delegate
    func didLocationSave(lat: Double?, lng: Double?, address: String?) {
        self.userLatitude = "\(lat ?? 0.0)"
        self.userLongitude = "\(lng ?? 0.0)"
        self.userAddress = address ?? ""
        self.addressTextField.text = self.userAddress
    }
}

extension EditProfileVC {
    // MARK: - Web Services
    private func updateUserProfile() {
        self.view.showLoader()
        SEGAnalytics.shared().track(Analytics.updatedProfile)
        DataManager.shared.saveProfile(self.profileData) { (_, error, message, _) in
            self.view.hideLoader()
            if error == nil {
                self.profileData = CreateProfile()
                TopMessage.shared.showMessageWithText(text: message ?? "", completion: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.refreshUserDetail.value), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.radiusChange.value), object: nil)
                self.didTapLeftButton()
                UserManager.shared.deleteUserUploadedDocFromLocal()
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
}
