//
//  TermsAndPolicyVC.swift
//  Steve
//
//  Created by Parth Grover on 5/10/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import WebKit
import Analytics

class TermsAndPolicyVC: UIViewController {

    @IBOutlet weak var webContainerView: UIView!
    @IBOutlet weak var topView: TopBarView!
    
    
    var isViewTypePolicy:Bool = false
    var webView:WKWebView!
    
    
    override func loadView() {
        super.loadView()
        self.webView = WKWebView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        SEGAnalytics.shared().track(Analytics.loadedAPpage)
//        SEGAnalytics.shared().track(Analytics.loadedAscreen)
        SEGAnalytics.shared().screen(AnalyticsScreens.TermsAndPolicyVC)

        self.webView.navigationDelegate = self
        self.webContainerView.addSubview(self.webView)
        self.setupNavigationBar()
        self.showWebViewPage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        self.setupWebView()
    }
    
    //MARK: - Custom Method
    private func setupWebView() {
        var newFrame = self.webView.frame
        newFrame.size.width = self.webContainerView.frame.size.width
        newFrame.size.height = self.webContainerView.frame.size.height
        self.webView.frame = newFrame
    }
    
    private func setupNavigationBar() {
        var title = ""
        if isViewTypePolicy {
            title = AppText.privacy
        } else {
            title = AppText.terms
        }
        self.topView.setHeaderData(title: title, leftButtonImage: AppImage.backButton)
        self.topView.delegate = self
    }
    
    private func showWebViewPage() {
        var url:URL
        if isViewTypePolicy {
            url = URL(string:APIServices.privacyPolicy)!
        }else {
            url = URL(string:APIServices.termsAndConditons)!
        }
        self.webView.load(URLRequest(url: url))
    }
    
}


extension TermsAndPolicyVC:WKNavigationDelegate, TopBarViewDelegate {
    
    //MARK: - TopBarViewDelegate
    func didTapLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        TopMessage.shared.showMessageWithText(text: error.localizedDescription, completion: nil)
        self.view.hideLoader()
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.view.showLoader()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.hideLoader()
    }
}
