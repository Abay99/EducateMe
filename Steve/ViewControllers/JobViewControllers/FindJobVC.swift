//
//  FindJobVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 21/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import SVPullToRefresh
import CoreLocation
import Analytics

class FindJobVC: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var addressContainerView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var distanceButton: UIButton!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var sliderDistanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: CustomSlider!
    @IBOutlet weak var jobTableView: UITableView!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var topBarHeightConst: NSLayoutConstraint!
    @IBOutlet weak var sliderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addressViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    // Variables
    var jobs:[Job] = []
    private var latitude:String = ""
    private var longitude:String = ""
    private var radius:Int = UserManager.shared.activeUser?.defaultRadius ?? 50
    private var currentPage = 1
    private var totalPages = 1
    private let refreshControl = UIRefreshControl()
    private var isPulledToRefresh: Bool = false
    private var isSliderValueChanged = false
    private var conflictId = 0
    //Variable for Direct Job
    var isOpeningForDirectJob = false;
    var locationManager = CoreLocationManager.sharedInstance
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        badgeLabel.isHidden = true
        //SEGAnalytics.shared().track(Analytics.loadedAPpage)
         SEGAnalytics.shared().screen(AnalyticsScreens.findJobVC)
        NotificationCenter.default.addObserver(self, selector: #selector(radiusChanged), name: NSNotification.Name(rawValue: NotificationName.radiusChange.value), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: NotificationName.refreshData.value), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefreshLogin), name: NSNotification.Name(rawValue: NotificationName.refreshDataOnLogin.value), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetNewData), name: NSNotification.Name(rawValue: NotificationName.resetNewData.value), object: nil)
        self.updateUI()
        self.setupData()
        //self.view.addSubview(uiview!);
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        badgeView.addGestureRecognizer(tap)
        
        backButton.isHidden = true
        if UserDefaults.bool(forKey: AppStatus.isLoginDone) == false {
            badgeView.isHidden = true
            backButton.isHidden = false
        }
        if isOpeningForDirectJob == true {
            addressContainerView.isHidden = true;
            addressView.isHidden = true
            sliderView.isHidden = true;
            badgeView.isHidden = true
            sliderViewHeight.constant = 0
            topBarHeightConst.constant = 54
            addressViewHeight.constant = 0
            backButton.isHidden = false
            titleLabel.text = NavTitle.directJob
            self.tabBarController?.tabBar.isHidden = true
        }
        else {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let vc = UIStoryboard.navigateToFindJobVC()
        vc.isOpeningForDirectJob = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func foo(_ function: (Int) -> Int) -> Int {
        return function(function(5))
    }
    
    func bar<T: BinaryInteger>(_ number: T) -> T {
        return number * 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isOpeningForDirectJob == false {
            self.navigationController?.tabBarController?.tabBar.isHidden = false
        }
        guard (UserManager.shared.activeUser) != nil else {
            self.navigationController?.tabBarController?.tabBar.isHidden = true
            return
        }
        if UserDefaults.bool(forKey: AppStatus.isLoginDone) == true {
            self.getDirectJobCound();
        }
        
        backButton.isHidden = true
        if UserDefaults.bool(forKey: AppStatus.isLoginDone) == false {
            badgeView.isHidden = true
            backButton.isHidden = false
        }
        if isOpeningForDirectJob == true {
            addressContainerView.isHidden = true;
            addressView.isHidden = true
            sliderView.isHidden = true;
            badgeView.isHidden = true
            sliderViewHeight.constant = 0
            topBarHeightConst.constant = 54
            addressViewHeight.constant = 0
            backButton.isHidden = false
            titleLabel.text = NavTitle.directJob
            self.tabBarController?.tabBar.isHidden = true
        }
        else {
            
            self.tabBarController?.tabBar.isHidden = false
        }
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Method
    
   
    
    @objc func radiusChanged() {
        self.radius = UserManager.shared.activeUser?.defaultRadius ?? 50
        self.distanceSlider.value = Float(self.radius)
        self.distanceButton.setTitle("\(self.radius)km", for: .normal)
    }
    
    @objc func refreshData(notif:NSNotification) {
        //self.handlePullToRefresh()
        
        if let notification = notif.object as? Notifications {
            let type = notification.type ?? 0
            switch type {
            case 1...3:
                self.view.makeToast(message: AppText.refreshScreen)
            default:
                break
            }
        }
    }
    
    @objc func resetNewData(notif:Notification) {
        self.clearAll()
        self.jobTableView.dataSource = self
        self.jobTableView.delegate = self
        if isOpeningForDirectJob == false {
            self.getRelatedJob();
        }
        else if isOpeningForDirectJob == true {
            self.getDirectJob()
        }
        if UserDefaults.bool(forKey: AppStatus.isLoginDone) == true {
            self.getDirectJobCound();
        }
    }
    
    private func updateUI() {
        self.sliderUISetup()
        self.topView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 30))
        view.backgroundColor = .clear
        self.jobTableView.tableFooterView = view
        self.jobTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.handlePullToRefresh), for: UIControlEvents.valueChanged)
        showWelcomeBoard()
    }
    
    private func showWelcomeBoard() {
        if !UserDefaults.standard.bool(forKey: AppText.welcome) {
            WelcomeAlert.showWelcomeBoard()
            UserDefaults.standard.set(true, forKey: AppText.welcome)
            UserDefaults.standard.synchronize()
        }
    }
    
    private func sliderUISetup() {
        let thumbImage = UIImage(named: AppImage.sliderThumb)
        self.distanceSlider.setThumbImage(thumbImage, for: .normal)
        self.distanceSlider.setThumbImage(thumbImage, for: .disabled)
        self.distanceSlider.setThumbImage(thumbImage, for: .highlighted)
        self.distanceSlider.tintColor = CustomColor.preferenceSelectionColor
        self.distanceSlider.maximumTrackTintColor = .white
        self.distanceSlider.value = Float(self.radius)
    }
    
    private func setupData() {
        if isOpeningForDirectJob == true {
            self.getDirectJob()
        }
        else {
            self.distanceButton.setTitle("\(self.radius)km", for: .normal)
            self.jobTableView.dataSource = self
            self.jobTableView.delegate = self
            self.loadNextPage()
            if UserDefaults.bool(forKey: AppStatus.isLoginDone) == true {
                self.getRelatedJob()
            } else {
                self.getUserCurrentLocation()
            }  
        }
    }
    
    private func updateData() {
        
    }
    
    @objc func handleRefreshLogin() {
        self.view.showLoader()
        self.jobs.removeAll()
        self.jobTableView.reloadData()
        handlePullToRefresh();
        backButton.isHidden = true
        if UserDefaults.bool(forKey: AppStatus.isLoginDone) == false {
            badgeView.isHidden = true
            backButton.isHidden = false
        }
        if isOpeningForDirectJob == true {
            addressContainerView.isHidden = true;
            addressView.isHidden = true
            sliderView.isHidden = true;
            badgeView.isHidden = true
            sliderViewHeight.constant = 0
            topBarHeightConst.constant = 54
            addressViewHeight.constant = 0
            backButton.isHidden = false
            titleLabel.text = NavTitle.directJob
            self.tabBarController?.tabBar.isHidden = true
        }
        else {
            badgeView.isHidden = false
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    @objc func handlePullToRefresh() {
        
        isPulledToRefresh = true
        self.currentPage = 1
        self.totalPages = 1
        if isOpeningForDirectJob == true {
            self.getDirectJob(true)
        }
        else {
            self.getRelatedJob(true)
             if UserDefaults.bool(forKey: AppStatus.isLoginDone) == true {
                self.getDirectJobCound();
            }
        }
    }
    
    private func clearAll() {
        self.jobs.removeAll()
        self.currentPage = 1
        self.totalPages = 1
        self.jobTableView.reloadData()
        self.jobTableView.dataSource = nil
        self.jobTableView.delegate = nil
    }
    
    private func loadNextPage() {
        self.jobTableView.addInfiniteScrolling {
            if self.isPulledToRefresh {
                self.jobTableView.infiniteScrollingView.stopAnimating()
                return
            }
            if self.jobs.count > 0 {
                if self.currentPage < self.totalPages {
                    self.currentPage = self.currentPage + 1
                    if self.isOpeningForDirectJob == true {
                         self.getDirectJob(true);
                    } else {
                        self.getRelatedJob(true);
                    }
                } else {
                    self.jobTableView.infiniteScrollingView.stopAnimating()
                }
            } else {
                self.jobTableView.infiniteScrollingView.stopAnimating()
            }
        }
    }
    
    private func validateUserAndProceed(_ index:Int) {
        if let _ = UserManager.shared.activeUser {
            if self.validateEligibleForJob(index) {
                //self.applyJob(index)
//                AlertView.showAlertWithMessage("", AppText.applyJobText, buttons: ["No", "Yes"], hasBorder:true, coloredIndex: 0) { [weak self](tag) in
//                    if tag == 1 {
                self.fetchMyProfile(index:index)
                   // }
              //  }
                
                //self.fetchMyProfile(index:index)
            } else {
                AlertView.showAlertWithMessage("", "This job does not match your category. Do you want to apply?", buttons: ["No", "Yes"], hasBorder:true, coloredIndex: 0) { [weak self](tag) in
                    if tag == 1 {
                        //self?.applyJob(index)
                        self?.fetchMyProfile(index:index)
                    }
                }
            }
        } else {
            AlertActionView.showSignupActionSheet { (actionType) in
                switch actionType {
                case .signUp:
                    self.openSignUpScreen()
                    break
                case .signIn:
                    self.openSignInScreen()
                    break
                default:
                    break
                }
            }
        }
    }
    
    private func validateEligibleForJob(_ index: Int) -> Bool {
        var isEligible = false
        let jobCategoryId = self.jobs[index].categoryId
        let selectedCategory = UserManager.shared.activeUser.userCategories
        for cat in selectedCategory ?? [] {
            if cat.categoryId == jobCategoryId {
                isEligible = true
            }
        }
        return isEligible
    }
    
    private func openSignUpScreen() {
        let vc = UIStoryboard.navigateToLoginSignupVC()
        vc.isFromFindJobVC = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openSignInScreen() {
        let vc = UIStoryboard.navigateToLoginSignupVC()
        vc.isFromFindJobVC = true
        vc.currentSelectedView = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func confilctAction(_ action:ConfilctAction) {
        switch action {
        case .moreJobs:
            break
        case .conflict:
            self.refreshWithConflictDetail()
            break
        }
    }
    
    private func refreshWithConflictDetail() {
        let vc = UIStoryboard.navigateToJobDetailVC()
        vc.jobId = self.conflictId
        vc.latitude = self.latitude
        vc.longitude = self.longitude
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - IBActions
    @IBAction func refreshClicked() {
        self.view.endEditing(true)
        self.clearAll()
        SEGAnalytics.shared().track(Analytics.searchedJob, properties:[AnalyticsPorperties.searchtext:self.addressTextField.text ?? ""])
        self.addressTextField.text = ""
        self.radius = UserManager.shared.activeUser?.defaultRadius ?? 50
        self.distanceSlider.value = Float(self.radius)
        self.sliderDistanceLabel.text = "\(self.radius)km"
        self.distanceButton.setTitle("\(self.radius)km", for: .normal)
         if isOpeningForDirectJob == false {
            self.getRelatedJob();
        }
        self.getDirectJobCound()
    }
    
    @IBAction func distanceButtonAction() {
        self.view.endEditing(true)
        self.sliderDistanceLabel.text = "\(self.radius)km"
        self.distanceSlider.value = Float(self.radius)
        UIView.animate(withDuration: 0.5, animations: {
            self.sliderView.alpha = 1.0
            self.addressContainerView.alpha = 0.0
        }) { (success) in
            self.sliderView.isHidden = false
            self.addressContainerView.isHidden = true
        }
    }
    
    @IBAction func doneButtonAction() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5, animations: {
            self.sliderView.alpha = 0.0
            self.addressContainerView.alpha = 1.0
        }) { (success) in
            self.sliderView.isHidden = true
            self.addressContainerView.isHidden = false
        }
        if self.isSliderValueChanged {
            self.distanceButton.setTitle("\(self.radius)km", for: .normal)
            self.clearAll()
            self.getRelatedJob()
        }
        self.isSliderValueChanged = false
    }
    
    @IBAction func distanceSliderValueChanged() {
        self.distanceSlider.value = Float(roundf(self.distanceSlider.value / 5) * 5)
        self.radius = Int(self.distanceSlider.value)
        self.isSliderValueChanged = true
        self.sliderDistanceLabel.text = "\(self.radius)km"
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        if UserManager.shared.isLoggedInUser() == false {
            Utilities.logOutUser("");
        }
    }
    
}

extension FindJobVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.jobs.count == 0 {
            self.jobTableView.setEmptyMessage("No Job Found")
        } else {
            self.jobTableView.restore()
        }
        return self.jobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.jobCell.value) as? JobCell
        if cell == nil {
            //self.jobTableView.register(UINib.init(nibName: CellIdentifier.jobCell.value, bundle: nil), forCellReuseIdentifier: CellIdentifier.jobCell.value)
            cell = JobCell.jobCell()
            cell?.jobCompletion = { [unowned self] (index) in
                self.view.endEditing(true)
                if self.jobs[index].isApplied == 0 {
                    self.validateUserAndProceed(index)
                } else {
                    //
                }
            }
        }
        cell?.setupData(job:self.jobs[indexPath.row],index:indexPath)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        // Move to job details VC
        self.jobTableView.deselectRow(at: indexPath, animated: true)
        let vc = UIStoryboard.navigateToJobDetailVC()
        vc.jobId = self.jobs[indexPath.row].id ?? 0
        vc.latitude = self.latitude
        vc.longitude = self.longitude
        
        vc.jobDetail = self.jobs[indexPath.row]
        vc.completion = { [weak self] (jobStatus, isApplied) in
            if jobStatus == JobConfirmStatus.cancelled {
                self?.jobs[indexPath.row].status = 0
                self?.jobs[indexPath.row].isApplied = 0
                self?.jobTableView.reloadRows(at: [indexPath], with: .fade)
            } else if jobStatus == JobConfirmStatus.pending {
                self?.jobs[indexPath.row].status = jobStatus.rawValue
                self?.jobs[indexPath.row].isApplied = isApplied
                self?.jobTableView.reloadRows(at: [indexPath], with: .fade)
            } else if jobStatus == JobConfirmStatus.cancelledByEmployer {
                self?.jobs.remove(at: indexPath.row)
                self?.jobTableView.deleteRows(at: [indexPath], with: .fade)
                self?.jobTableView.reloadData()
            } else if jobStatus.rawValue != self?.jobs[indexPath.row].status {
                if jobStatus.rawValue > 1 {
                    self?.jobs.remove(at: indexPath.row)
                    self?.jobTableView.deleteRows(at: [indexPath], with: .fade)
                    self?.jobTableView.reloadData()
                } else {
                    self?.jobs[indexPath.row].status = jobStatus.rawValue
                    self?.jobTableView.reloadRows(at: [indexPath], with: .fade)
                }
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension FindJobVC {
    // MARK: - WebService
    func getRelatedJob(_ isLoadingMore:Bool = false) {
        if isLoadingMore == false { // load first time, then show loader
            //self.tabBarController?.view.showLoader()
        }
        
        for _ in 0...10 {
            
            let job = Job.init(id: 1, userId: 1, jobName: "Maths, Physics, Chemistry", description: "Teaching" , categoryId: 1, wagePerHour: "11", jobStartTime: "  10:11pm", jobEndTime: "11:00Pm", duration: "1 Hour", address: "Hsr Layout Banglore", latitude: 1.1, longitude: 2.1, status: 1, useName: "use Name", categoryName: "Shah Rukh khan", categoryImageUrl: "https://static-koimoi.akamaized.net/wp-content/new-galleries/2014/09/photo-story-teachers-day-1.jpg", parentCategoryName: "parentCategoryName", parentCategoryId: 1, distance: 2.2, isApplied: 1, employerPhoneNumber: "employerPhoneNumber", employerAddress: "employerAddress", employerWebsite: "www.google.com")
            
            self.jobs.append(job);
        }
        self.jobTableView.delegate = self
        self.jobTableView.dataSource = self
        jobTableView.reloadData()
        
//         SEGAnalytics.shared().track(Analytics.searchedJob, properties:[AnalyticsPorperties.searchtext:self.addressTextField.text])
        
//        DataManager.shared.getJobs(latitude:self.latitude, longitude:self.longitude, radius:self.radius, requestPage:self.currentPage, keyword:self.addressTextField.text ?? "") { (jobs, _, error, status, currentPage, totalPages) in
//            self.view.hideLoader()
//            if isLoadingMore == false {
//                self.tabBarController?.view.hideLoader()
//            } else {
//                self.jobTableView.infiniteScrollingView.stopAnimating()
//            }
//            if self.isPulledToRefresh == true {
//                self.clearAll()
//                self.refreshControl.endRefreshing()
//                self.isPulledToRefresh = false
//                self.jobTableView.delegate = self
//                self.jobTableView.dataSource = self
//            }
//            if error == nil {
//                self.currentPage = currentPage
//                self.totalPages = totalPages
//                self.jobs.append(contentsOf: jobs ?? [])
//                self.jobTableView.delegate = self
//                self.jobTableView.dataSource = self
//                self.jobTableView.reloadData()
//            } else {
//                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
//            }
//        }
    }
    
    
    
    
    func getDirectJob(_ isLoadingMore:Bool = false) {
        if isLoadingMore == false { // load first time, then show loader
            //self.view.showLoader()
        }
        
        for _ in 0...10 {
            
            let job = Job.init(id: 1, userId: 1, jobName: "Teacher Class", description: "Teaching" , categoryId: 1, wagePerHour: "11", jobStartTime: "10:11pm", jobEndTime: "11:00Pm", duration: "1 Hour", address: "Hsr Layout Banglore", latitude: 1.1, longitude: 2.1, status: 2, useName: "use Name", categoryName: "Category Name", categoryImageUrl: "http://www.google.com", parentCategoryName: "parentCategoryName", parentCategoryId: 1, distance: 2.2, isApplied: 1, employerPhoneNumber: "employerPhoneNumber", employerAddress: "employerAddress", employerWebsite: "www.google.com")
            
            self.jobs.append(job);
        }
        self.jobTableView.delegate = self
        self.jobTableView.dataSource = self
        jobTableView.reloadData()
//        DataManager.shared.getDirectJobs(requestPage:self.currentPage) { (jobs, _, error, status, currentPage, totalPages) in
//            if isLoadingMore == false {
//                self.view.hideLoader()
//            } else {
//                self.jobTableView?.infiniteScrollingView?.stopAnimating()
//            }
//            if self.isPulledToRefresh == true {
//                self.clearAll()
//                self.refreshControl.endRefreshing()
//                self.isPulledToRefresh = false
//                self.jobTableView.delegate = self
//                self.jobTableView.dataSource = self
//            }
//            if error == nil {
//                self.currentPage = currentPage
//                self.totalPages = totalPages
//                self.jobs.append(contentsOf: jobs ?? [])
//                self.jobTableView.delegate = self
//                self.jobTableView.dataSource = self
//                self.jobTableView.reloadData()
//            } else {
//                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
//            }
//        }
    }
    
    
    private func fetchMyProfile(index:Int) {
        self.view.showLoader()
        DataManager.shared.showProfile { (userData, _, error, status) in
            self.view.hideLoader()
            if error == nil {
                if userData?.accountNo?.count ?? 0 > 5 {
                    AlertView.showAlertWithMessage("", AppText.applyJobText, buttons: ["No", "Yes"], hasBorder:true, coloredIndex: 0) { [weak self](tag) in
                        if tag == 1 {
                            self?.applyJob(index)
                        }
                    }
                }
                else {
                    AlertView.showAlertWithMessageVertical("", AppText.updateAccountFieldMsg, buttons: ["Cancel", "Add"], hasBorder:true, coloredIndex:1) { (index) in
                        if index == 1 {
                            self.paymentInfo()
                        }
                    }
                    //TopMessage.shared.showMessageWithText(text: AppText.updateAccountFieldMsg , completion: nil)
                }
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
    
        private func paymentInfo() {
            let vc = UIStoryboard.navigateToAccountVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    
    private func applyJob(_ index:Int) {
        
        self.view.showLoader()
        let job = self.jobs[index]
        SEGAnalytics.shared().track(Analytics.appliedToJob, properties: [AnalyticsPorperties.jobId:job.id, AnalyticsPorperties.wagePerHour:job.wagePerHour, AnalyticsPorperties.currency:"USD",AnalyticsPorperties.category:job.parentCategoryName , AnalyticsPorperties.subCategory:job.categoryName , AnalyticsPorperties.duration:job.duration, AnalyticsPorperties.jobStartTime:job.jobStartTime,  AnalyticsPorperties.jobEndTime:job.jobEndTime, AnalyticsPorperties.distanceFromEmployee:job.distance])
        DataManager.shared.initiateForApply(jobId: self.jobs[index].id ?? 0) { ( conflictId, _, message, error) in
            self.view.hideLoader()
            if error == nil {
                if conflictId == nil {
                    TopMessage.shared.showMessageWithText(text: message ?? "", completion: nil)
                    self.jobs[index].status = JobConfirmStatus.pending.rawValue
                    self.jobs[index].isApplied = 1
                    let indexPath = IndexPath(row: index, section: 0)
                    self.jobTableView.reloadRows(at: [indexPath], with: .fade)
                } else {
                    self.conflictId = conflictId ?? 0
                    AlertActionView.showConflictActionSheet(completion: { [unowned self](action) in
                        self.confilctAction(action)
                    })
                }
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
    
    func getDirectJobCound() {
        
        self.badgeLabel.isHidden = true
        DataManager.shared.getDirectJobsCount { (success, error, totalPages) in
            if error == nil {
                if totalPages ?? 0 > 0 {
                    self.badgeLabel.isHidden = false
                    self.badgeLabel.text = "\(totalPages ?? 0)"
                }
                else {
                    self.badgeLabel.isHidden = true
                }
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
}

extension FindJobVC: UITextFieldDelegate {
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.addressTextField {
            if (textField.text?.count ?? 0) > 0 {
                self.clearAll()
                self.getRelatedJob()
                SEGAnalytics.shared().track(Analytics.searchedJob, properties:[AnalyticsPorperties.searchtext:textField.text ?? ""])
            }
            else if (textField.text?.count ?? 0) == 0 {
                self.clearAll()
                self.getRelatedJob()
                SEGAnalytics.shared().track(Analytics.searchedJob, properties:[AnalyticsPorperties.searchtext:textField.text])
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.addressTextField {
            if (textField.text?.count ?? 0) == 0 && string == " " {
                return false
            }
            else if (textField.text?.count ?? 0) == 1 && string == "" {
                textField.text = ""
                self.clearAll()
                getRelatedJob(false)
                textField.resignFirstResponder()
                return true
            }
        }
        return true
    }
}

extension FindJobVC:LocationManagerDelegate {
    // MARK: - Location
    private func getUserCurrentLocation() {
        locationManager.delegate = self
        if locationManager.locationServicesEnabled() {
            if locationManager.locationHasBeenAsked() {
                self.view.showLoader()
                locationManager.startLocationUpdating()
            } else {
                locationManager.askPermissionAndStartLocationUpdate()
            }
        } else {
            TopMessage.shared.showMessageWithText(text: AppText.LocationDisbaled, completion: nil)
        }
    }
    
    // Location Delegate
    func locationManagerUserCurrentLocationAndAddress(location: CLLocation, address: String) {
        self.view.hideLoader()
        self.latitude = "\(location.coordinate.latitude)"
        self.longitude = "\(location.coordinate.longitude)"
        self.locationManager.delegate = nil
        self.getRelatedJob()
    }
    
    func locationManagerFailedToGetLocation(error: Error) {
        self.view.hideLoader()
        var _ = "Failed to fetch Location."
        if !Utilities.isNetworkReachable() {
            //locationError = "Please check your internet connection."
        }
        self.locationManager.delegate = nil
        //self.view.showToast(locationError, duration: 2, completion: nil)
    }
    
    func locationServiceDisabled() {
        self.view.hideLoader()
        // User Denied Location go to Disabled Location Screen
        self.locationManager.delegate = nil
        TopMessage.shared.showMessageWithText(text: AppText.LocationDisbaled, completion: nil)
    }
    
    func deviceLocationDisabled() {
        self.view.hideLoader()
        self.locationManager.delegate = nil
        TopMessage.shared.showMessageWithText(text: AppText.LocationDisbaled, completion: nil)
    }
}

extension FindJobVC: TopBarViewDelegate {
    // MARK: - Top Bar Delegate
    func didTapLeftButton() {
        self.navigationController?.popViewController(animated: true);
    }
    
    func didTapRightButton(_ btn: UIButton?) {
        
    }
    
    private func moveBack() {
        
    }
}
