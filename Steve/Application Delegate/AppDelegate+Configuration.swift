//
//  AppDelegate+Configuration.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces
import Analytics
import Segment_Firebase
extension AppDelegate {
    /**
     Configures Device token
     */
    func updateDeviceToken(deviceToken: String) {
        DataManager.shared.updateToken(token: deviceToken) { (_, _, error) in
            if error != nil {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
    
    func updateGoogleSDK() {
        
        GMSPlacesClient.provideAPIKey(kGoogleKey)
        GMSServices.provideAPIKey(kGoogleKey)
    }
    
    func initSegmentAnalytics() {
        
        let configuration = SEGAnalyticsConfiguration.init(writeKey: kSegAnalyticsKey)
        configuration.use(SEGFirebaseIntegrationFactory.instance())
        configuration.trackApplicationLifecycleEvents = true;
        //configuration.recordScreenViews = true;
        SEGAnalytics.setup(with: configuration)
        SEGAnalytics.shared().track(Analytics.appInstallationEvent)
    }
}
