//
//  UIStoryboard+Additions.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIStoryboard Extension
extension UIStoryboard {

    /**
     Convenience Initializers to initialize storyboard.

     - parameter storyboard: String of storyboard name
     - parameter bundle:     NSBundle object
     
     - returns: A Storyboard object
     */
    convenience init(storyboard: String, bundle: Bundle? = nil) {
        self.init(name: storyboard, bundle: bundle)
    }
    
    
    /**
     Initiate view controller with view controller name.
    
     - returns: A UIView controller object
     */
    func instantiateViewController<T: UIViewController>() -> T {
        var fullName: String = NSStringFromClass(T.self)
        
        
        if let range = fullName.range(of: ".", options: .backwards) {
            fullName = fullName.substring(from: range.upperBound)
        }
        
        guard let viewController = self.instantiateViewController(withIdentifier: fullName) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(fullName) ")
        }
        
        return viewController
    }
    
    //MARK: - AllStoryboards
//    private class func onboardingStoryBoard() -> UIStoryboard {
//        return UIStoryboard(name: "Payment", bundle: nil)
//    }
    
    private class func loginStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "LoginSignUp", bundle: nil)
    }
    
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    private class func profileStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Profile", bundle: nil)
    }
    
    private class func jobsStroyboard() -> UIStoryboard {
        return UIStoryboard(name: "Jobs", bundle: nil)
    }
    
    private class func SettingStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Setting", bundle: nil)
    }
    
    //MARK: - AllViewControllers
    class func navigateToOnboardingVC() -> OnBoardingVC {
        return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "OnboardingVC") as! OnBoardingVC
    }
    
    class func navigateToLoginSignupVC() -> LoginSignUpVC {
        return UIStoryboard.loginStoryboard().instantiateViewController(withIdentifier: "LoginSignUpVC") as! LoginSignUpVC
    }

    class func navigateToTermsAndPolicyVC() -> TermsAndPolicyVC {
        return UIStoryboard.loginStoryboard().instantiateViewController(withIdentifier: "TermsAndPolicyVC") as! TermsAndPolicyVC
    }
    
    class func navigateToVerifyEmailVC() -> VerifyEmailVC {
        return UIStoryboard.loginStoryboard().instantiateViewController(withIdentifier: "VerifyEmailVC") as! VerifyEmailVC
    }
    
    class func navigateToForgotPasswordVC() -> ForgotPasswordVC{
        return UIStoryboard.loginStoryboard().instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
    }
    
    class func navigateToResetPasswordConfirmVC() -> ResetPasswordConfirmationVC{
        return UIStoryboard.loginStoryboard().instantiateViewController(withIdentifier: "ResetPasswordConfirmationVC") as! ResetPasswordConfirmationVC
    }
    
    class func navigateToFBSignUpVC() -> FBSignUpVC{
        return UIStoryboard.loginStoryboard().instantiateViewController(withIdentifier: "FBSignUpVC") as! FBSignUpVC
    }
    
//
//    class func navigateToSettingsVC() -> SettingsVC {
//        return UIStoryboard.settingStoryboard().instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
//    }
//
//    class func navigateToProfileVC() -> ProfileVC {
//        return UIStoryboard.settingStoryboard().instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
//    }
//
//    class func navigateToEditProfileVC() -> EditProfileVC {
//        return UIStoryboard.settingStoryboard().instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
//    }
//    
//    class func forgotPasswordVC() -> ForgotPasswordVC{
//        return UIStoryboard.loginStoryboard().instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
//    }
//
//
//    class func navigateToDashboard() -> DashboardVC {
//        return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
//    }
//
//    class func navigateToBookingView () -> CalendarViewController {
//        return UIStoryboard.bookingStoryboard().instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
//
//    }
//
//    class func navigateToSelectAddressVC() -> SelectAddressVC {
//        return UIStoryboard.loginStoryboard().instantiateViewController(withIdentifier: "SelectAddressVC") as! SelectAddressVC
//    }
//    
//    class func navigateToCreateFirstVC() -> CreateListFirstVC {
//       return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "CreateListFirstVC") as! CreateListFirstVC
//    }
//
//    class func navigateToCreateListingPickupDeliveryAvailabilityVC() -> CreateListingPickupDeliveryAvailabilityVC {
//        return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "CreateListingPickupDeliveryAvailabilityVC") as! CreateListingPickupDeliveryAvailabilityVC
//    }
//
//    class func navigateToCreatePhotoVC() -> CreateListImageVC {
//        return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "CreateListImageVC") as! CreateListImageVC
//    }
//
//    class func navigateToReviewPostVC() -> ReviewPostVC {
//        return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "ReviewPostVC") as! ReviewPostVC
//    }
//
//    class func navigateToProductDetailVC() -> ProductDetailVC {
//        return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
//    }
//
//    class func navigateToAskQuestionVC() -> AskQuestionVC {
//        return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "AskQuestionVC") as! AskQuestionVC
//    }
//
//    class func navigateToCreditCardPaymentVC() -> CreditCardPaymentViewController {
//        return UIStoryboard.paymentStoryboard().instantiateViewController(withIdentifier: "CreditCardPaymentViewController") as! CreditCardPaymentViewController
//    }
//    
//    class func navigateToSecurityDepositVC() -> SecurityDepositVC {
//        return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "SecurityDepositVC") as! SecurityDepositVC
//    }
//
//    class func navigateToReviewBookingVC() -> ReviewBookingVC {
//        return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "ReviewBookingVC") as! ReviewBookingVC
//    }
//
//    class func navigateToItemRequestVC() -> ItemRequestVC {
//        return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "ItemRequestVC") as! ItemRequestVC
//    }
//
//    class func navigateToAddPaymentVC() -> AddPaymentVC {
//        return UIStoryboard.paymentStoryboard().instantiateViewController(withIdentifier: "AddPaymentVC") as! AddPaymentVC
//    }
//
//    class func navigateToPaymentVC() -> PaymentVC {
//        return UIStoryboard.paymentStoryboard().instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
//    }
    class func navigateToAddProfileVC() -> AddProfileVC {
        return UIStoryboard.profileStoryboard().instantiateViewController(withIdentifier: "AddProfileVC") as! AddProfileVC
    }
    
    class func navigateToLocationPermissionVC()-> LocationPermissionVC {
        return UIStoryboard.profileStoryboard().instantiateViewController(withIdentifier: "LocationPermissionVC") as! LocationPermissionVC
    }
    
    class func navigateToMapVC() -> MapVC {
        return UIStoryboard.profileStoryboard().instantiateViewController(withIdentifier: "MapVC") as! MapVC
    }
    
    // ProflieVCs
    class func getProfileVCs(identifier:String) -> UIViewController {
        return UIStoryboard.profileStoryboard().instantiateViewController(withIdentifier: identifier)
    }
    
    // Dashboard
    class func navigateToTabVC()-> CustomTabBarController {
        return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
    }
    
    class func navigateToFindJobVC()-> FindJobVC {
        return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "FindJobVC") as! FindJobVC
    }
    
    // JobDetails
    class func navigateToJobDetailVC()-> JobDetailVC {
        return UIStoryboard.jobsStroyboard().instantiateViewController(withIdentifier: "JobDetailVC") as! JobDetailVC
    }
    
    class func navigateToHistoryVC() -> HistoryVC {
        return UIStoryboard.jobsStroyboard().instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
    }
    
    // My Profile
    class func navigateToSettingVC() -> SettingVC {
        return UIStoryboard.profileStoryboard().instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
    }
    
//    class func navigateToUploadDocumentVC() -> UploadDocumentVC {
//        return UIStoryboard.profileStoryboard().instantiateViewController(withIdentifier: "UploadDocumentVC") as! UploadDocumentVC
//    }
    
    class func navigateToDocumentTypeVC() -> DocumentTypeVC {
        return UIStoryboard.profileStoryboard().instantiateViewController(withIdentifier: "DocumentTypeVC") as! DocumentTypeVC
    }//DocImageVC
    
    class func navigateToDocImageVC() -> DocImageVC {
        return UIStoryboard.profileStoryboard().instantiateViewController(withIdentifier: "DocImageVC") as! DocImageVC
    }//DocImageVC

    
    class func navigateToEditProfileVC() -> EditProfileVC {
        return UIStoryboard.profileStoryboard().instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
    }
    
    class func navigateToCategoryVC() -> CategoryVC {
        return UIStoryboard.profileStoryboard().instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
    }
    
    // Settings
    class func navigateToAccountVC() -> AccountVC {
        return UIStoryboard.SettingStoryboard().instantiateViewController(withIdentifier: "AccountVC") as! AccountVC
    }
    
    class func navigateToChangePasswordVC() -> ChangePasswordVC {
        return UIStoryboard.SettingStoryboard().instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
    }
    
    class func navigateToWorkHistoryVC() -> WorkHistoryVC {
        return UIStoryboard.SettingStoryboard().instantiateViewController(withIdentifier: "WorkHistoryVC") as! WorkHistoryVC
    }
    
    class func navigateToAddWorkHistoryVC() -> AddWorkHistoryVC {
        return UIStoryboard.SettingStoryboard().instantiateViewController(withIdentifier: "AddWorkHistoryVC") as! AddWorkHistoryVC
    }
}
