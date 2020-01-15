//
//  CustomTabBarController.swift
//  Steve
//
//  Created by Sudhir Kumar on 21/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    // IBOutlets
    @IBOutlet weak var customTabView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet var tabs: [UIButton]!
    @IBOutlet weak var tabBarView: CustomTabBar!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateForNotification), name: NSNotification.Name(rawValue: NotificationName.badgeCount.value), object: nil)
        
        self.customTabView.frame.size.width = self.view.frame.width
        self.tabBarView.addSubview(self.customTabView)
        self.updateUI()
        self.tabChange(btn: tabs[0])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard (UserManager.shared.activeUser) != nil else {
            self.tabBarView.isHidden = true
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Custom Method
    private func updateUI() {
        self.customTabView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.shadowTabView, shadowOpacity: 0.7)
        // comment if not show . as per application badge count
        if UIApplication.shared.applicationIconBadgeNumber > 0 {
            self.tabs[2].setImage(UIImage(named:AppImage.notifDot), for: .normal)
        } else {
            self.tabs[2].setImage(UIImage(named:AppImage.notifDeactive), for: .normal)
        }
        // Comment to this line
    }

    @objc func updateForNotification(_ notification: NSNotification) {
        let isNewNotification = notification.object as? Bool ?? false
        if isNewNotification {
            self.tabs[2].setImage(UIImage(named:AppImage.notifDot), for: .normal)
        } else {
            self.tabs[2].setImage(UIImage(named:AppImage.notifDeactive), for: .normal)
        }
    }
    
    // MARK: - IBActions
    @IBAction func tabChange(btn:UIButton) {
        self.selectedIndex = btn.tag
        for button in tabs {
            if button.tag == btn.tag {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
        if self.selectedIndex == 2 {
            self.tabs[2].setImage(UIImage(named:AppImage.notifDeactive), for: .normal)
        }
        
        switch btn.tag {
        case 0:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.resetNewData.value), object: nil)
        case 1:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.resetHistory.value), object: nil)
        case 2:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.resetNotification.value), object: nil)
        case 3:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.refreshUserDetail.value), object: nil)
        default:
            break
        }
    }
}

class CustomTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = 56
        return size
    }
}
