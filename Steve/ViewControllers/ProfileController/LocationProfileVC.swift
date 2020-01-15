//
//  LocationProfileVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 15/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import CoreLocation
import Analytics

class LocationProfileVC: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var distanceSlider: CustomSlider!
    
    // Variables
    var profileData:CreateProfile?
    var locationManager = CoreLocationManager.sharedInstance
    var userLatitude = "0.0"
    var userLongitude = "0.0"
    var userAddress:String = ""
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        SEGAnalytics.shared().screen(AnalyticsScreens.Location)
        self.setupUI()
        //self.setupData()
        NotificationCenter.default.addObserver(self, selector: #selector(viewOnMap), name: NSNotification.Name(rawValue: NotificationName.getLocation.value), object: nil)
        self.viewOnMap()
        addressTextField.clearButtonMode = .whileEditing;
        //self.locationManager.askPermissionAndStartLocationUpdate();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Custom Method
    private func setupUI() {
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
        //imgView.backgroundColor = .red
        imgView.image = UIImage(named: AppImage.pinIcon)
        imgView.contentMode = .scaleAspectFit
        leftImageView.addSubview(imgView)
        self.addressTextField.leftView = leftImageView
        self.addressTextField.leftViewMode = .always
    }
    
    private func setupData() {
        profileList.address = self.userAddress
        profileList.latitude = self.userLatitude
        profileList.longitude = self.userLongitude
        profileList.radius = Int(self.distanceSlider.value)
    }
    
    private func updateUIData() {
        self.addressTextField.text = self.userAddress
    }
    
    @objc private func viewOnMap() {
        self.perform(#selector(checkForPermissionAndLoad), with: nil, afterDelay: 0.0)
    }
    
    // MARK: - IBActions
    @IBAction func locationButtonTapped() {
        let vc = UIStoryboard.navigateToMapVC()
        vc.lat = Double(self.userLatitude) ?? 0.0
        vc.lng = Double(self.userLongitude) ?? 0.0
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func sliderValueChanged() {
        self.distanceSlider.value = Float(roundf(self.distanceSlider.value / 5) * 5)
        self.distanceLabel.text = "\(Int(self.distanceSlider.value))km"
    }
    
    @IBAction func nextButtonClicked() {
        // Move dashboard not to check location is present or not
        self.setupData()
        self.saveUserProfile()
    }
}

extension LocationProfileVC:LocationManagerDelegate {
    @objc private func checkForPermissionAndLoad() {
        DispatchQueue.main.async {
            self.getUserCurrentLocation()
        }
    }
    
    // MARK: - Location Update
    private func getUserCurrentLocation() {
        //locationManager.delegate = self
        LogManager.logMessage(mesage:"inside Get User current location method))")
        self.locationManager.delegate = self
        if locationManager.locationServicesEnabled() {
            if locationManager.locationHasBeenAsked() {
                self.view.showLoader()
                locationManager.startLocationUpdating()
            } else {
                //locationManager.askPermissionAndStartLocationUpdate()
                let vc = UIStoryboard.navigateToLocationPermissionVC()
                vc.completion = {  (isAllow) in
                    if isAllow {
                        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        DispatchQueue.main.async {
                            //self.locationManager.delegate = self
                            self.locationManager.askPermissionAndStartLocationUpdate();
                        }
                        //}
                    }
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = UIStoryboard.navigateToLocationPermissionVC()
            vc.completion = {  (isAllow) in
                if isAllow {
                    //DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    DispatchQueue.main.async {
                        //self.locationManager.delegate = self
                        self.locationManager.askPermissionAndStartLocationUpdate();
                    }
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Location Delegate
    func locationManagerUserCurrentLocationAndAddress(location: CLLocation, address: String) {
        self.view.hideLoader();
        
        LogManager.logMessage(mesage:"Recived location will move to map vc))")
        self.userLatitude = "\(location.coordinate.latitude)"
        self.userLongitude = "\(location.coordinate.longitude)"
        self.userAddress = address
        self.locationManager.delegate = nil
        self.updateUIData()
        let vc  = self.navigationController?.viewControllers.last?.childViewControllers.last
        if vc is LocationProfileVC {
            self.locationButtonTapped()
        }
    }
    
    func locationManagerFailedToGetLocation(error: Error) {
        self.view.hideLoader()
        var _ = "Failed to fetch Location."
        if !Utilities.isNetworkReachable() {
            //locationError = "Please check your internet connection."
        }
        self.locationManager.delegate = nil
        //self.view.showToast(locationError, duration: 2, completion: nil)
    }
    
    func locationServiceDisabled() {
        self.view.hideLoader()
        // User Denied Location go to Disabled Location Screen
        self.locationManager.delegate = nil
        TopMessage.shared.showMessageWithText(text: AppText.LocationDisbaled, completion: nil)
    }
    
    func deviceLocationDisabled() {
        self.view.hideLoader()
        self.locationManager.delegate = nil
        TopMessage.shared.showMessageWithText(text: AppText.LocationDisbaled, completion: nil)
    }
}

extension LocationProfileVC {
    // MARK: - WebServices
    private func saveUserProfile() {
        self.view.showLoader()
        SEGAnalytics.shared().track(Analytics.acquisitionAccountConfirmed)
        
        DataManager.shared.saveProfile(profileList) { (_, error, message, _) in
            self.view.hideLoader()
            UserManager.shared.deleteUserUploadedDocFromLocal()
            if error == nil {
                let email = UserManager.shared.activeUser.email

                var isWorkHistory = false
                if profileList.workExperience != nil {
                    isWorkHistory = true
                }
                var isBioAdded = false
                if profileList.bio != nil {
                    isBioAdded = true;
                }
                var isYoutubeAdded = false
                if profileList.youtubeLink != nil {
                    isYoutubeAdded = true
                }
                SEGAnalytics.shared().track(Analytics.onboardingAboutInfo, properties: [AnalyticsPorperties.name:profileList.name , AnalyticsPorperties.age:profileList.age , AnalyticsPorperties.email:email , AnalyticsPorperties.phone:profileList.phoneNumber , AnalyticsPorperties.gender : profileList.gender , AnalyticsPorperties.id:UserManager.shared.activeUser.id])
                
                SEGAnalytics.shared().track(Analytics.onboardingLocationPreference, properties: [AnalyticsPorperties.locationDistance:profileList.radius ,AnalyticsPorperties.locationSet:true])
                
                SEGAnalytics.shared().track(Analytics.onboardingPersonalInfo, properties: [AnalyticsPorperties.workExperience:profileList.workExperience , AnalyticsPorperties.workHistory:isWorkHistory , AnalyticsPorperties.bioAdded:isBioAdded , AnalyticsPorperties.youtubeLinkAdded:isYoutubeAdded])
                CreateProfileRefresh.refresh() // reInitialize data
                SEGAnalytics.shared().identify("a user's id", traits: [AnalyticsPorperties.email : email ?? "" , AnalyticsPorperties.name : profileList.name ?? ""])
                
                
                
                self.moveToAppropriateVC()
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
    
    private func moveToAppropriateVC() {
        if (self.parent as! AddProfileVC).isFromFindJobVC {
            // Move To Find JobVC
            self.navigationController?.popToRootViewController(animated: true)
        } else if (self.parent as! AddProfileVC).isFromJobDetail {
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
}

extension LocationProfileVC: MapVCDelegate {
    // MARK: - MapVC Delegate
    func didLocationSave(lat: Double?, lng: Double?, address: String?) {
        self.userLatitude = "\(lat ?? 0.0)"
        self.userLongitude = "\(lng ?? 0.0)"
        self.userAddress = address ?? ""
        self.updateUIData()
    }
}
