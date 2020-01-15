//
//  LocationPermissionVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 17/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics
class LocationPermissionVC: UIViewController {

    // IBOutlets
    @IBOutlet weak var topView: TopBarView!

    // Variables
    var completion:((_ isAllow: Bool) -> Void)?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        SEGAnalytics.shared().track(Analytics.loadedAPpage)
//        SEGAnalytics.shared().track(Analytics.loadedAscreen)
        SEGAnalytics.shared().screen(AnalyticsScreens.LocationPermission)

        self.setupTopView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Custom Method
    private func setupTopView() {
        self.topView.setHeaderData(title: NavTitle.locationPermission, leftButtonImage: AppImage.backButton)
        self.topView.delegate = self
    }
    
    // MARK: - IBActions
    @IBAction func allowClicked() {
        self.didTapLeftButton()
            if self.completion != nil {
                self.completion!(true)
            }
        SEGAnalytics.shared().track(Analytics.locationPermissionGranted)
    }
    
    @IBAction func cancelClicked() {
        if self.completion != nil {
            self.completion!(false)
        }
        self.didTapLeftButton()
    }
}

extension LocationPermissionVC:TopBarViewDelegate {
    func didTapLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
}
