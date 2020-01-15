//
//  Utilities.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
import UIKit
import Reachability

class Utilities: NSObject {
    
    class func setScrollViewWithKeyboardState(scrllView: UIScrollView, keyboardStateOpen: Bool = false, keyboardSizeHeight: CGFloat = 0.0, viewToScroll: UIView = UIView(), minusYOffset: CGFloat = UIApplication.shared.statusBarFrame.height) {

        scrllView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardStateOpen ? keyboardSizeHeight : 0.0), right: 0.0)
        scrllView.contentOffset = CGPoint(x: 0.0, y: (keyboardStateOpen ? viewToScroll.frame.origin.y - minusYOffset : 0.0))
    }
    
    /**
     Global function to check if the input object is initialized or not.
     
     - parameter value: value to verify for initialization
     
     - returns: true if initialized
     */
    class func isObjectInitialized(_ value: AnyObject?) -> Bool {
        guard let _ = value else {
            return false
        }
        return true
    }
    
    
    
    /*
     For selecting Image (Action Sheet)
     */
    class func openActionSheetWith(title:String = "Choose Option", arrOptions: [String] = ["Add photo from gallery", "Take a new photo"], openIn viewController: UIViewController?, optionSelected: @escaping (_ index: Int) -> Void) {
        
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.title = title
        // Add Items in action sheet
        for title in arrOptions {
            var style : UIAlertActionStyle = .default
            if title == AppText.deleteList{
                style = .destructive
            }
            let alertAction: UIAlertAction = UIAlertAction(title: title, style: style, handler: { action in
                if let alertIndex = actionSheet.actions.index(of: action) {
                    optionSelected(alertIndex)
                }
            })
            actionSheet.addAction(alertAction)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            // Do nothing
        })
        actionSheet.addAction(cancelAction)
        
        // Open
        var controller: UIViewController? = viewController
        if viewController == nil {
            controller = (UIApplication.shared.keyWindow?.rootViewController)
        }
        controller?.present(actionSheet, animated: true) {
            // Do nothing
        }
        
    }
    
   

    // *************** Log out *****************
    class func logOutUser(_ message: String) {
//        AppToast.showToastWithMessage(message)
        let deviceToken = UserDefaults.string(forKey: AppText.deviceToken)
        clearCache()
        UserDefaults.save(value: true, forKey: AppStatus.isWalkThroughDone)
        UserDefaults.save(value: true, forKey: AppText.welcome)
        UserDefaults.save(value: deviceToken, forKey: AppText.deviceToken)
        let vc = UIStoryboard.navigateToLoginSignupVC()
        kAppDelegate.navController?.viewControllers = [vc]
        kAppDelegate.window?.rootViewController = nil
        kAppDelegate.navController = UINavigationController(rootViewController: vc)
        kAppDelegate.navController?.navigationBar.isHidden = true
        kAppDelegate.window?.rootViewController = kAppDelegate.navController
        kAppDelegate.window?.makeKeyAndVisible()
       //UserDefaults.bool(forKey: AppStatus.isLoginDone) == false
        UserDefaults.standard.set(false, forKey: AppStatus.isLoginDone)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    fileprivate class func clearCache() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserManager.shared.activeUser = nil
        UserDefaults.standard.synchronize()
//       kAppDelegate.removeAllNotificationForApp()
    }
    
    // ******************* Validity Check *********************
    class func validateTextFieldInputs(_ textFields: UITextField...) -> (Bool, textField: UITextField, message:String) {
        var isValidated = true
        var message:String = ""
        var currentTextField: UITextField = UITextField()
        for textFld in textFields {
            let textField = textFld
            textField.text = textField.textByTrimmingWhiteSpacesAndNewline()
//            if textField.keyboardType == .numberPad && !textField.isTextFieldEmpty(){
//                if Int(textField.text!)! <= 0 {
//                    isValidated = false
//                    currentTextField = textField
//                    message = textField.accessibilityLabel! + AppText.globalNonZeroMessage
//                    break
//                }
//            }
            if textField.isTextFieldEmpty() {
                isValidated = false
                currentTextField = textField
                message = textField.accessibilityLabel! + AppText.globalEmptyMessage
                break
            }
        }
        return (isValidated, currentTextField, message)
    }
    
    class func validateTextViewInputs(_ textViews: UITextView...) -> (Bool, textView: UITextView, message:String) {
        var isValidated = true
        var message:String = ""
        var currentTextView: UITextView = UITextView()
        for textView in textViews {
            let textV = textView
            textV.text = textV.textByTrimmingWhiteSpacesAndNewline()
            if textView.isTextViewEmpty() {
                isValidated = false
                currentTextView = textView
                message = textView.accessibilityLabel! + AppText.globalEmptyMessage
                break
            }
        }
        return (isValidated, currentTextView, message)
    }
    
    class func isYoutubeLink(checkString: String) -> Bool {
        let youtubeRegex = "(http(s)?:\\/\\/)?(www\\.|m\\.)?youtu(be\\.com|\\.be)(\\/watch\\?([&=a-z]{0,})(v=[\\d\\w]{1,}).+|\\/[\\d\\w]{1,})"
        
        let youtubeCheckResult = NSPredicate(format: "SELF MATCHES %@", youtubeRegex)
        return youtubeCheckResult.evaluate(with: checkString)
    }
    
    class func isBSBNumber(checkString: String) -> Bool {
        let bsbRegex = "^\\d{3}-?\\d{3}$"
        
        let bsbCheckResult = NSPredicate(format: "SELF MATCHES %@", bsbRegex)
        return bsbCheckResult.evaluate(with: checkString)
    }
    
    class func isAccountNumber(checkString: String) -> Bool {
        let bsbRegex = "^\\d{1}-?\\d{1}$"
        
        let bsbCheckResult = NSPredicate(format: "SELF MATCHES %@", bsbRegex)
        return bsbCheckResult.evaluate(with: checkString)
    }
    
    class func isBSBNumberSecond(checkString: String) -> Bool {
        let bsbRegex = "^\\d{2}-?\\d{4}$"
        
        let bsbCheckResult = NSPredicate(format: "SELF MATCHES %@", bsbRegex)
        return bsbCheckResult.evaluate(with: checkString)
    }
    
    class func isValidName(checkString: String) -> Bool {
        let nameRegEx = "[a-zA-Z]+"
        let result = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return result.evaluate(with: checkString)
    }
    
    class func isNetworkReachable() -> Bool {
        let reach: Reachability = Reachability.forInternetConnection()
        return reach.currentReachabilityStatus() != .NotReachable
    }
    
    class func deviceSpecificHeight(height : CGFloat) -> CGFloat {
        let screenRatio = UIScreen.main.bounds.size.height / ScreenSize.SCREEN_HEIGHT
        let newHeight = height * screenRatio
        return newHeight
    }
    
    class func deviceSpecificWidth(width : CGFloat) -> CGFloat {
        let screenRatio = UIScreen.main.bounds.size.width / ScreenSize.SCREEN_WIDTH
        let newWidth = width * screenRatio
        return newWidth
    }
    
    class func fixOrientation(img:UIImage) -> UIImage {
        
        if img.imageOrientation == UIImageOrientation.up {
            return img
        }
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    class func fetchDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    class func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width:newWidth,height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width :newWidth,height : newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    // COnversion Of date to string
    class func dateFromString(strDate: String, formate: String) -> Date {
        debugPrint(strDate)
        if strDate == "" { return Date()}
        let dateFormatter: DateFormatter = DateFormatter() //[[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = formate//"dd/MM/yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date: Date = dateFormatter.date(from: strDate) ?? Date() as Date
        return date
    }
    
    class func stringFromDate(date: Date, formate: String) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = formate //"yyyy-MM-dd"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    class func stringFromStringDateWithFormat(strDate:String, formate:String) -> String {
        if strDate == "" {
            return ""
        }
        let newDate = Utilities.dateFromString(strDate: strDate, formate: "yyyy-MM-dd HH:mm:ss")
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = formate
        let strDate = dateFormatter.string(from: newDate)
        return strDate
    }
    
    class func stringFromStringDateWithSuffix(strDate:String) -> String {
        if strDate == "" {
            return ""
        }
        let newDate = Utilities.dateFromString(strDate: strDate, formate: "yyyy-MM-dd HH:mm:ss")
        return Utilities.convertDateFormate(date: newDate)
    }
    
    class func convertDateFormate(date : Date) -> String{
        // Day
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MMM"
        let newDate = dateFormate.string(from: date)
        
        var day  = "\(anchorComponents.day!)"
        switch (day) {
        case "1" , "21" , "31":
            day.append("st")
        case "2" , "22":
            day.append("nd")
        case "3" ,"23":
            day.append("rd")
        default:
            day.append("th")
        }
        return (day + " " + newDate)//.lowercased()
    }
    
    class func timeStringFromDate(strDate:String) -> String {
        if strDate == "" {
            return ""
        }
        let newDate = Utilities.dateFromString(strDate: strDate, formate: "yyyy-MM-dd HH:mm:ss")
        let dateFormatter: DateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "hh:mma"
        dateFormatter.timeZone = NSTimeZone.local
        let strDate = dateFormatter.string(from: newDate)
        return strDate.lowercased()
    }
    
    class func jobDurationInHours(startDateStr:String, endDateStr:String) -> String {
        if startDateStr == "" && endDateStr == "" {
            return "N/A"
        }
        let startDate = Utilities.dateFromString(strDate: startDateStr, formate: "yyyy-MM-dd HH:mm:ss")
        let endDate = Utilities.dateFromString(strDate: endDateStr, formate: "yyyy-MM-dd HH:mm:ss")
        
        let seconds = UInt(endDate.timeIntervalSince(startDate))
        var hoursString = "N/A"
        
        if seconds >= 3600 {
            let hours = (seconds/60) / 60
            let minutes = seconds % 60
            hoursString = "\(hours)hrs "
            if minutes > 0 {
             hoursString.append("\(minutes)min")
            }
        } else if seconds >= 60 {
            let minutes = seconds / 60
            hoursString = "\(minutes)min"
        }
        return hoursString
    }
    
    class func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude) )
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        if (UIDevice.current.model.range(of: "iPad") != nil) {
            return label.frame.height + 20
        }else{
            return label.frame.height
        }
    }
    
}


