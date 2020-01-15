//
//  DocImageVC.swift
//  Steve
//
//  Created by Rishi Kumar on 24/10/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Kingfisher
import Analytics

class DocImageVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var webView: UIWebView!
    var imageView: UIImageView!
    var imageUrl:String?
    var docName:String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       // SEGAnalytics.shared().track(Analytics.loadedAPpage)
        SEGAnalytics.shared().screen(AnalyticsScreens.DocImageVC)        
        self.topView.setHeaderData(title: "", leftButtonImage: AppImage.backButton)
        self.titleLabel.text = docName;
        topView.delegate = self
        webView.scalesPageToFit = true
        self.topView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.view.showLoader()
        if let url = URL.init(string: imageUrl ?? "steve.com") {
            let request = URLRequest.init(url: url)
            webView.loadRequest(request)
            webView.delegate = self;
        }
    }
}

extension DocImageVC:TopBarViewDelegate {
    // MARK: - TopBarDelegate
    func didTapLeftButton() {
        self.dismiss(animated: true) {
        }
    }
    func didTapRightButton(_ btn: UIButton?) {
    }
}
extension DocImageVC:UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.view.hideLoader()
    }
}
