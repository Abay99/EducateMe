//
//  AppDelegate+Notification.swift
//  Steve
//
//  Created by Sudhir Kumar on 18/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0 ..< deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        
         //token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        debugPrint("token:\(token)")
        UserDefaults.save(value: token, forKey: AppText.deviceToken)
        // Check if logged in and update device token
        if UserDefaults.bool(forKey: AppStatus.isLoginDone) == true {
            self.updateDeviceToken(deviceToken:token)
        }
       // let alert = UIAlertController(title: token, message: "Your message count =" + "\(token.count)", preferredStyle: .alert)
        //let cancelButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
       // alert.addAction(cancelButton)
        //UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UserNotificationDelegate

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint(error.localizedDescription)
    }

    func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let aps = userInfo["aps"] as? NSDictionary
        if let dict = aps?["data"] as? Dictionary<String, Any> {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                let notif :Notifications = try JSONDecoder().decode(Notifications.self, from: jsonData)
                if UserManager.shared.isLoggedInUser() {
                    if let count = (aps?["badge"] ?? 0) as? Int {
                        UIApplication.shared.applicationIconBadgeNumber = count;
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.badgeCount.value), object: true)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.newNotification.value), object: nil)
                    notificationRefreshAction(notif)
                }
            } catch _ {
                //
            }
        }
        completionHandler([.badge, .sound])
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler _: @escaping () -> Void) {
        // Push Notification
        let userInfo = response.notification.request.content.userInfo
        let aps = userInfo["aps"] as? NSDictionary
        if let dict = aps?["data"] as? Dictionary<String, Any> {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                let notifList:Notifications = try JSONDecoder().decode(Notifications.self, from: jsonData)
                if UserManager.shared.isLoggedInUser() {
                    notificationAction(notifList)
                }
            } catch _ {
               // kAppDelegate.openDashboard()
            }
        } else {
            kAppDelegate.openDashboard()
        }
    }

    // MARK: - Helper Method
    func configureRichNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted: Bool, error: Error?) in
            if error != nil {
                debugPrint((error?.localizedDescription)!)
            }
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                debugPrint("Permission not granted")
            }
        }
        UNUserNotificationCenter.current().delegate = self
    }

    func notificationAction(_ notifInfo: Notifications?) {
        guard let notif = notifInfo else { return }
        if notif.type == 3 || notif.type == 4 {
            kAppDelegate.openDashboard()
        }
        else if notif.type == 12 {
            showMyProfile(noti: notifInfo)
        }
        else {
            UIApplication.shared.applicationIconBadgeNumber -= 1
            self.moveToJobDetailVC(notif)
        }
    }

    func notificationRefreshAction(_ notifInfo: Notifications?) {
        guard let notif = notifInfo else { return }
        var name = ""
        switch (notif.type ?? 0) {
        case 1:
            name = NotificationName.refreshData.value
        case 2:
            name = NotificationName.refreshData.value
        case 3...4:
            name = NotificationName.refreshData.value
        case 10:
            name = NotificationName.refreshData.value
        default:
            break
        }
        self.sendNotification(name: name, object: notif)
    }
    
    func sendNotification(name:String, object:Notifications?) {
        if name == "" {
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: object)
    }
    
    @objc func markNotificationAsRead(_ notification:Any) {
        if notification is Notifications {
//            DataManager.shared.setNotificationStatus(notificationId:[notif.data?.id ?? 0]) { (_, error) in
//                DispatchQueue.main.async {
//                    if error == nil {
//                        UIApplication.shared.applicationIconBadgeNumber -= 1
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppText.badgeCount), object: UIApplication.shared.applicationIconBadgeNumber)
//                    }
//                }
//            }
        }
    }
}

extension AppDelegate {
    // MARK: - Navigate VC
    // Navigate To JobDetailVC
    func moveToJobDetailVC(_ notif:Notifications?) {
        if navController != nil {
            navController = nil
        }
        let notifVC = UIStoryboard.navigateToJobDetailVC()
        notifVC.jobId = notif?.jobId ?? 0
        let newNavController = self.getNavigationController(viewController: notifVC)
        window?.rootViewController = newNavController
        window?.makeKeyAndVisible()
    }

    // navigateToNotificationTab
    func moveToNotificationTab() {
        if navController != nil {
            navController = nil
        }
        let dashboard = UIStoryboard.navigateToTabVC()
        dashboard.selectedIndex = 2
        window?.rootViewController = dashboard
        window?.makeKeyAndVisible()
    }
    
    // MARK: - Get Nav Controller
    private func getNavigationController(viewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: viewController)
        nav.interactivePopGestureRecognizer?.isEnabled = false
        nav.isNavigationBarHidden = true
        return nav
    }
    
    private func openWorkHistory(userProfile:User , _ notif:Notifications?) {
        if navController != nil {
            navController = nil
        }
        
        
        if navController != nil {
            navController = nil
        }
        
        let vc = UIStoryboard.navigateToWorkHistoryVC()
        vc.histories = userProfile.userWorkHistory
        let notifVC = UIStoryboard.navigateToFindJobVC()
       // notifVC.jobId = notif?.jobId ?? 0
        let newNavController = self.getNavigationController(viewController: notifVC)
        window?.rootViewController = newNavController
        window?.makeKeyAndVisible()
        newNavController.pushViewController(vc, animated: true)
    }

}

extension AppDelegate {
//    // MARK: - Web Services
//    @objc func getBadgeCount() {
//        DataManager.shared.getNotificationCount { (count, chatUnreadCount, _, error) in
//            DispatchQueue.main.async {
//                if error == nil {
//                    if chatUnreadCount != 0 {
//                        DashboardVC.changeChatIcon(nil)
//                    }
//
//                    UIApplication.shared.applicationIconBadgeNumber = count ?? 0
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:AppText.badgeCount), object: count ?? 0)
//                }
//            }
//        }
//    }
    
    private func showMyProfile(noti:Notifications?) {
        DataManager.shared.showProfile { (userData, _, error, status) in
            if error == nil {
                if let userData = userData {
                    self.openWorkHistory(userProfile: userData, noti);
                }
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    } }
