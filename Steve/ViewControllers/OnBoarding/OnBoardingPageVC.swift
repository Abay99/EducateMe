//
//  OnBoardingPageVC.swift
//  Steve
//
//  Created by Parth Grover on 5/8/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class OnBoardingPageVC: UIPageViewController,UIScrollViewDelegate {

    weak var tutorialDelegate: OnBoardingPageVCDelegate?
    
    var currentPage : Int = 0
    let shouldScrollIndefinitely = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        // Listen to the UIPageViewController's scroll view scroll events
        for testView: Any in self.view.subviews {
            let scrollView = testView as! UIScrollView
            scrollView.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //manage page view controller
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newPageViewController(page: "First"),
                self.newPageViewController(page: "Second"),
                self.newPageViewController(page: "Third")]
    }()
    
    private func newPageViewController(page: String) -> UIViewController {
        return UIStoryboard.mainStoryboard() .
            instantiateViewController(withIdentifier: "OnBoarding\(page)VC")
    }
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self,
                                                        viewControllerAfter: visibleViewController) {
            scrollToViewController(nextViewController)
        }
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    fileprivate func scrollToViewController(_ viewController: UIViewController,
                                            direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'tutorialDelegate' of the new index.
                            self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(nextViewController, direction: direction)
        }
    }

    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    fileprivate func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            tutorialDelegate?.tutorialPageViewController(tutorialPageViewController: self, didUpdatePageIndex: index)
            currentPage = index
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: UIPageViewControllerDataSource

extension OnBoardingPageVC: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // print("came in before VC")
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        currentPage = previousIndex + 1
        // print("before currentPage onPageView = \(currentPage)")
        
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // print("came in after VC")
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        currentPage = nextIndex
        // print("after currentPage onPageView = \(currentPage)")
        
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
}

extension OnBoardingPageVC: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
    
}

extension OnBoardingPageVC
{
    
    // MARK: - ScrollView Delegates
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.scrollViewDidScroll(beforeFirstPage: scrollView) || self.scrollViewDidScrollFurtherThanLastPage(scrollView) {
            self.resetScrollViewPosition(scrollView)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if self.scrollViewDidScroll(beforeFirstPage: scrollView) || self.scrollViewDidScrollFurtherThanLastPage(scrollView) {
            targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
    }
    
    func scrollViewDidScroll(beforeFirstPage scrollView: UIScrollView) -> Bool {
        return self.currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width
    }
    
    func scrollViewDidScrollFurtherThanLastPage(_ scrollView: UIScrollView) -> Bool {
        return self.currentPage == orderedViewControllers.count && scrollView.contentOffset.x > scrollView.bounds.size.width
    }
    
    func resetScrollViewPosition(_ scrollView: UIScrollView) {
        // Note: The page view controller's internal scroll view content offset starting position is actually equals to the width of the content view, i.e. 320px for an iPhone 5
        scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
    }
}


protocol OnBoardingPageVCDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func tutorialPageViewController(tutorialPageViewController: OnBoardingPageVC,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func tutorialPageViewController(tutorialPageViewController: OnBoardingPageVC,
                                    didUpdatePageIndex index: Int)
}
