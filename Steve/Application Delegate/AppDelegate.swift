//
//  AppDelegate.swift
//  Steve
//
//  Created by Parth Grover on 5/2/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import IQKeyboardManagerSwift
import UserNotifications
import Crashlytics
import Analytics
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navController: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //UIApplication.shared.statusBarView?.backgroundColor = UIColor.white
        updateGoogleSDK();
        initSegmentAnalytics();
        enableInputAccessoryView()
        UserDefaults.save(value: "", forKey: AppText.deviceToken)
        configureRichNotifications()
        //FirebaseApp.configure()
        if launchOptions != nil{
            let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification]
            if userInfo != nil {
            }
        } else {
            setUpApplication()
        }
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        // Setup FB
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
              Fabric.with([Crashlytics.self])
        
        Branch.setUseTestBranchKey(true)
        // listener for Branch Deep Link data
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            // do stuff with deep link data (nav to page, display content, etc)
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        SEGAnalytics.shared().track(Analytics.applicationOpenedEvent)

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.getLocation.value), object: nil)
        configureRichNotifications()
        //self.performSelector(inBackground: #selector(self.getBadgeCount), with: nil)
        if UIApplication.shared.isRegisteredForRemoteNotifications == false {
            configureRichNotifications()
        }
//        if UserDefaults.string(forKey: AppText.deviceToken).count <= 0 {
//            configureRichNotifications()
//        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        
        Branch.getInstance().application(app, open: url, options: options)

        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // handler for Universal Links
        Branch.getInstance().continue(userActivity)
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // handler for Push Notifications
        Branch.getInstance().handlePushNotification(userInfo)
    }
    
}

extension AppDelegate {
    func setUpApplication(){
        //updateGoogleSDK()
        openInitialViewController()
        //openDashboard();
    }
    
    func openInitialViewController() {
        if UserDefaults.bool(forKey: AppStatus.isWalkThroughDone) == true {
            if UserDefaults.bool(forKey: AppStatus.isLoginDone) == true
            {
                if (UserManager.shared.activeUser?.isProfileComplete == 0)
                {
                    // Move to profile view
                    openCreateProfileViewController()
                }
                else{
                    // Move to dashboard view
                    openDashboard()
                    //TopMessage.shared.showMessageWithText(text: "Will move to Dashboard shortly!", completion: nil)
                }
            }
            else{
                 //openDashboard()
                self.openLoginSignUpViewController()
            }
        } else {
            // open walkthrough
            //openDashboard()
            self.openOnboardingTutorialViewController()
        }
    }
    
    // Open Tutorialviewcontroller
    func openOnboardingTutorialViewController() {
        let objOnBoardingVC = UIStoryboard.navigateToOnboardingVC()
        navController = UINavigationController(rootViewController: objOnBoardingVC)
        navController?.isNavigationBarHidden = true
        window?.rootViewController = navController!
        window?.makeKeyAndVisible()
    }
    
    // Open Login/SignUp ViewController
    func openLoginSignUpViewController() {
        let loginVC = UIStoryboard.navigateToLoginSignupVC()
        navController = UINavigationController(rootViewController: loginVC)
        navController?.isNavigationBarHidden = true
        window?.rootViewController = navController!
        window?.makeKeyAndVisible()
    }
    
    // Open Login/SignUp ViewController
    func openCreateProfileViewController() {
        //let profileVC = UIStoryboard.navigateToAddProfileVC()
       let loginVC = UIStoryboard.navigateToLoginSignupVC()
        navController = UINavigationController(rootViewController: loginVC)
        navController?.isNavigationBarHidden = true
        window?.rootViewController = navController!
        window?.makeKeyAndVisible()
    }
    
    func openDashboard() {
        let dashboard = UIStoryboard.navigateToTabVC()
        window?.rootViewController = dashboard
        window?.makeKeyAndVisible()
    }
    
    fileprivate func enableInputAccessoryView() {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().toolbarTintColor = CustomColor.backgroundGreen
        IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().previousNextDisplayMode = .alwaysHide
    }
}

extension UIApplication {
//    var statusBarView: UIView? {
//        return value(forKey: "statusBar") as? UIView
//    }
    
    func handlePushNotification(_ userInfo: NSDictionary) {
        // Check applicationState
        if (applicationState == UIApplicationState.active) {
            // Application is running in foreground
        }
        else if (applicationState == UIApplicationState.background || applicationState == UIApplicationState.inactive) {
            // Application is brought from background or launched after terminated
            handlePushNotification(userInfo)
        }
    }
}
