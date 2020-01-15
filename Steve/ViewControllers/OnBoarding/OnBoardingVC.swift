//
//  OnBoardingVC.swift
//  Steve
//
//  Created by Parth Grover on 5/7/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics
class OnBoardingVC: UIViewController {

    // IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    // Variables
    var currentIndex : Int = 0
    var isViewOnly:Bool = false
    var tutorialPageViewController: OnBoardingPageVC? {
        didSet {
            tutorialPageViewController?.tutorialDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //SEGAnalytics.shared().track(Analytics.loadedAPpage)
        
        SEGAnalytics.shared().screen(AnalyticsScreens.OnBoardingVC)
        // Do any additional setup after loading the view.
        self.nextButton.isHidden = false
        self.pageControl.currentPageIndicatorTintColor = CustomColor.onBoardingPage1IndicatorColor
        pageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        let angle = CGFloat(Double.pi/2)
        //self.skipButton.isHidden = self.isViewOnly
        pageControl.transform = pageControl.transform.rotated(by: angle)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        (UIApplication.shared.statusBarView? as AnyObject).backgroundColor = UIColor.clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // UIApplication.shared.statusBarView?.backgroundColor = UIColor.white
    }
    
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
        tutorialPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let pageViewController = segue.destination as? OnBoardingPageVC {
            pageViewController.tutorialDelegate = self
            self.tutorialPageViewController = pageViewController
        }
    }
    
    // MARK: - Action
    @IBAction func nextButtonClicked(_ sender: Any) {
        if currentIndex >= 2 {
            // Go To SignUpViewFromHere and mark GoThrough Done.
            if !isViewOnly {
                UserDefaults.save(value: true, forKey:AppStatus.isWalkThroughDone)
                kAppDelegate.openInitialViewController()
            }
            else  if isViewOnly {
                self.navigationController?.popViewController(animated: true)
            }
        }
        else{
          tutorialPageViewController?.scrollToViewController(index:currentIndex + 1)
        }
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        // Go To SignUpViewFromHere and mark GoThrough Done.
        if isViewOnly {
            self.navigationController?.popViewController(animated: true)
            return
        }
        UserDefaults.save(value: true, forKey:AppStatus.isWalkThroughDone)
        kAppDelegate.openInitialViewController()
    }
}


extension OnBoardingVC: OnBoardingPageVCDelegate {
    
    func tutorialPageViewController(tutorialPageViewController: OnBoardingPageVC, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func tutorialPageViewController(tutorialPageViewController: OnBoardingPageVC, didUpdatePageIndex index: Int) {
        currentIndex = index
        pageControl.currentPage = index
        if index == 0 {
            self.pageControl.currentPageIndicatorTintColor = CustomColor.onBoardingPage1IndicatorColor
        }
        else if index == 1 {
            self.pageControl.currentPageIndicatorTintColor = CustomColor.onBoardingPage2IndicatorColor
        }
        else{
            self.pageControl.currentPageIndicatorTintColor = CustomColor.onBoardingPage3IndicatorColor
        }
        
//        self.nextButton.isEnabled = (index >= 2 && self.isViewOnly) ? false : true
//        self.previousButton.isEnabled = (index > 0) ? true : false
    }
}
