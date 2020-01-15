//
//  AddProfileVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 15/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics

var profileList = CreateProfile()

class AddProfileVC: UIViewController {

    // IBOutlets
    @IBOutlet weak var profileBarView: ProgressProfileBar!
    @IBOutlet weak var containerView:UIView!

    // Variables
    var currentVC:UIViewController?
    var isFromJobDetail:Bool = false
    var isFromFindJobVC:Bool = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        SEGAnalytics.shared().track(Analytics.loadedAPpage)
//        SEGAnalytics.shared().track(Analytics.loadedAscreen)
        SEGAnalytics.shared().screen(AnalyticsScreens.addProfileVC)

        self.setNotifications()
        self.updateUI()
    }

    override func viewWillLayoutSubviews() {
        self.profileBarView.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Method
    private func updateUI() {
        self.profileBarView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.loadAppropriateVC(index: 0)
    }
    
    private func setNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(moveNext), name: NSNotification.Name(rawValue: NotificationName.moveNext.value), object: nil)
    }
    
    @objc func moveNext() {
        self.profileBarView.currentSelectedIndex += 1
        self.profileBarView.updateView()
        self.loadAppropriateVC(index: self.profileBarView.currentSelectedIndex)
    }
    
    private func loadAppropriateVC(index: Int) {
        var vc:UIViewController?
        self.remove(childViewController: self.currentVC)
        switch index {
        case 0:
            vc = UIStoryboard.getProfileVCs(identifier:"AboutProfileVC")
            break
        case 1:
            vc = UIStoryboard.getProfileVCs(identifier:"PersonalProfileVC")
            break
        case 2:
            vc = UIStoryboard.getProfileVCs(identifier:"PreferencesProfileVC")
            break
        case 3:
            vc = UIStoryboard.getProfileVCs(identifier:"LocationProfileVC")
            break
        default:
            break
        }
        if let expectedVC = vc {
            self.add(asChildViewController: expectedVC)
        }
    }
    
    private func add(asChildViewController vc:UIViewController) {
        self.addChildViewController(vc)
        self.currentVC = vc
        self.containerView.addSubview(self.currentVC!.view)
        vc.view.frame = self.containerView.bounds
        vc.didMove(toParentViewController: self)
    }
    
    private func remove(childViewController vc:UIViewController?) {
        if let removeVC = vc {
            removeVC.willMove(toParentViewController: nil)
            removeVC.view.removeFromSuperview()
            removeVC.removeFromParentViewController()
        }
    }
}
