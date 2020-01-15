//
//  JobDetailVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 21/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics

class JobDetailVC: UIViewController {

    // IBOutlets
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var jobTableView: UITableView!
    
    // Variables
    var jobId:Int = 0
    var latitude:String = ""
    var longitude:String = ""
    
    var jobDetail:Job?
    var tableData:[[String:String]] = [[:]]
    var completion:((_ status:JobConfirmStatus, _ isApplied:Int)->Void)?
    private var conflictId = 0
    private var isThreeDotsVisible:Bool {
        if jobDetail?.isApplied == 0 {
            return false
        } else {
            return ((jobDetail?.status ?? -1) == JobConfirmStatus.pending.rawValue) ? true : false
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //SEGAnalytics.shared().track(Analytics.loadedAPpage)
        SEGAnalytics.shared().screen(AnalyticsScreens.jobDetailVC)

        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: NotificationName.refreshData.value), object: nil)
        self.setupHeader()
        self.setupUI()
        self.setupData();
        //self.getJobDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Method
    @objc func refreshData(notif:NSNotification) {
        self.getJobDetails()
    }
    
    private func setupUI() {
        self.jobTableView.register(JobDetailCell.nib, forCellReuseIdentifier: "JobDetailCell")
        //self.jobTableView.tableHeaderView?.autoresizesSubviews = true
    }
    
    private func setupHeader() {
        self.topView.setHeaderData(title: NavTitle.jobDetails, leftButtonImage: AppImage.backButton, rightButtonImage: self.isThreeDotsVisible ? AppImage.threedots : "")
        if self.topView.delegate == nil {
            self.topView.delegate = self
        }
    }
    
    private func setupData() {
        self.jobTableView.dataSource = self
        self.jobTableView.delegate = self
        let headerView = JobDetailHeader.headerView()
        headerView.setupData(job: self.jobDetail)
        if headerView.jobTitleLabel.frame.size.height > 43 {
            var newFrame = headerView.frame
            newFrame.size.height += 43
            headerView.frame = newFrame
            //headerView.layoutIfNeeded()
        }
        headerView.completion = { [weak self] in
            if self?.jobDetail?.isApplied == 0 {
                SEGAnalytics.shared().track(Analytics.appliedToJob)
                self?.validateUserAndProceed()
            } else {
                self?.checkStatusAndProceed()
            }
        }
        self.jobTableView.tableHeaderView = headerView
        self.showTableData()
    }
    
    // API called according to status
    private func checkStatusAndProceed() {
        let currentStatus = self.jobDetail?.status
        switch currentStatus {
        case 2:
            self.changejobStatus(jobId:self.jobDetail?.id ?? 0, status: JobConfirmStatus.startCandidate.rawValue)
        case 4:
            //self.changejobStatus(jobId:self.jobDetail?.id ?? 0, status: JobConfirmStatus.completed.rawValue)
            self.changejobStatus(jobId:self.jobDetail?.id ?? 0, status: JobConfirmStatus.pendingForApproval.rawValue)
        default:
            break
        }
    }
    
    private func showTableData() {
        guard let jobData = self.jobDetail else { return }
        let jobHours = Utilities.timeStringFromDate(strDate: jobData.jobStartTime ?? "") + " to " + Utilities.timeStringFromDate(strDate: jobData.jobEndTime ?? "")
        let duration = (jobData.duration ?? "0") + " hrs" //Utilities.jobDurationInHours(startDateStr: jobData.jobStartTime ?? "", endDateStr: jobData.jobEndTime ?? "")
        self.tableData = [["title":"Job Id:", "value":"\(jobData.id ?? 0)"],["title":"Job Description:", "value":jobData.description ?? ""], ["title":"Job Hours:", "value": jobHours], ["title":"Job Duration:", "value":duration], ["title":"Job Posted by:", "value":jobData.useName ?? ""]]
        
        if (jobData.isApplied ?? 0) == 1  && (jobData.status ?? 0) != 1 {
            let extraData = [["title":"Employer Address:", "value":"\(jobData.employerAddress ?? "")"],["title":"Employer Contact number:", "value":"\(jobData.employerPhoneNumber ?? "")"],["title":"Employer Website address:", "value":"\(jobData.employerWebsite ?? "")"]]
            self.tableData.append(contentsOf: extraData)
        }
        self.jobTableView.reloadData()
    }
    
    private func validateUserAndProceed() {
        if let _ = UserManager.shared.activeUser {
            if self.validateEligibleForJob() {
                //self.applyJob()
                //self.fetchMyProfile()
                self.fetchMyProfile()
//                AlertView.showAlertWithMessage("", AppText.applyJobText, buttons: ["No", "Yes"], hasBorder:true, coloredIndex: 0) { [weak self](tag) in
//                    if tag == 1 {
//                        self?.fetchMyProfile()
//                    }
//                }
            } else {
                AlertView.showAlertWithMessage("", "This job does not match your category. Do you want to apply?", buttons: ["No", "Yes"], hasBorder: true, coloredIndex: 0) { [weak self](tag) in
                    if tag == 1 {
                       // self?.applyJob()
                        self?.fetchMyProfile()
                    }
                }
            }
        } else {
            self.proceedForRegistration()
        }
    }
    
    private func validateEligibleForJob() -> Bool {
        var isEligible = false
        let jobCategoryId = self.jobDetail?.categoryId ?? 0
        let selectedCategory = UserManager.shared.activeUser.userCategories
        for cat in selectedCategory ?? [] {
            if cat.categoryId == jobCategoryId {
                isEligible = true
            }
        }
        return isEligible
    }
    
    private func proceedForRegistration() {
        AlertActionView.showSignupActionSheet { (actionType) in
            switch actionType {
            case .facebookSignUp:
                self.openSignUpScreen()
                break
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
    
    private func openSignUpScreen() {
        let vc = UIStoryboard.navigateToLoginSignupVC()
        vc.isFromJobDetail = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openSignInScreen() {
        let vc = UIStoryboard.navigateToLoginSignupVC()
        vc.isFromJobDetail = true
        vc.currentSelectedView = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func confilctAction(_ action:ConfilctAction) {
        switch action {
        case .moreJobs:
            self.moveBack()
            break
        case .conflict:
            self.refreshWithConflictDetail()
            break
        }
    }
    
    private func refreshWithConflictDetail() {
        self.getJobDetails()
    }
    
    private func showCancelAlert() {
        AlertView.showAlertWithMessage("", AppText.cancelMessage, buttons: [AppText.cancelTitle], coloredIndex: 0) { (index) in
            if index == 0 {
                self.cancelJob()
            }
        }
    }
    
    private func moveBackWithCancelledStatus() {
        if (kAppDelegate.window?.rootViewController?.childViewControllers.count)! > 1 {
            if self.completion != nil {
                self.completion!(JobConfirmStatus.cancelledByEmployer , 0)
            }
            navigationController?.popViewController(animated: true)
        } else {
            kAppDelegate.openDashboard()
        }
    }
    // MARK: - IBActions

}

extension JobDetailVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let firstCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.jobFirstCell.value) as? JobFirstCell {
                firstCell.setupJobID(jobID:self.jobDetail?.id ?? 0)
                return firstCell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: JobDetailCell.identifier, for: indexPath) as? JobDetailCell {
                cell.setupData(self.tableData[indexPath.row],isLastCell: (indexPath.row == self.tableData.count - 1) ? true : false, index: indexPath.row)
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension JobDetailVC: TopBarViewDelegate {
    // MARK: - Top Bar Delegate
    func didTapLeftButton() {
        if (kAppDelegate.window?.rootViewController?.childViewControllers.count)! > 1 {
            if self.completion != nil {
                if (self.jobDetail?.status ?? 0) != 0 {
                    self.completion!(JobConfirmStatus(rawValue: self.jobDetail!.status!)!, self.jobDetail?.isApplied ?? 0)
                }
            }
            navigationController?.popViewController(animated: true)
        } else {
            kAppDelegate.openDashboard()
        }
        //self.navigationController?.popViewController(animated: true)
    }
    
    func didTapRightButton(_ btn: UIButton?) {
        if let button = btn {
            DropDown.showDropDownWithData(data: ["Cancel this job"], anchorView: button) { [unowned self] (index) in
                if index == 0 {
                    self.showCancelAlert()
                    //self.cancelJob()
                }
            }
        }
    }
    
    private func moveBack() {
        if (kAppDelegate.window?.rootViewController?.childViewControllers.count)! > 1 {
            navigationController?.popViewController(animated: true)
        } else {
            kAppDelegate.openDashboard()
        }
    }
}

extension JobDetailVC {
    // MARK: - Web Services
    private func getJobDetails() {
        self.view.showLoader()
        DataManager.shared.getJobDetails(jobId: (conflictId != 0) ? self.conflictId : self.jobId, lat:self.latitude, lng:self.longitude) { (result, _, message, error, status) in
            self.view.hideLoader()
            if status == 102 {
                TopMessage.shared.showMessageWithText(text: message ?? "", completion: nil)
                self.moveBackWithCancelledStatus()
                return
            }
            if error == nil {
                self.jobDetail = result
                self.setupHeader()
                self.setupData()
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
    
    private func fetchMyProfile() {
        self.view.showLoader()
        DataManager.shared.showProfile { (userData, _, error, status) in
            self.view.hideLoader()
            if error == nil {
                if userData?.accountNo?.trimmed().count ?? 0 > 5 {
                    AlertView.showAlertWithMessage("", AppText.applyJobText, buttons: ["No", "Yes"], hasBorder:true, coloredIndex: 0) { [weak self](tag) in
                        if tag == 1 {
                            self?.applyJob()
                        }
                    }
                    //self.applyJob()
                }
                else {
                    AlertView.showAlertWithMessageVertical("", AppText.updateAccountFieldMsg, buttons: ["Cancel", "Add"], hasBorder:true, coloredIndex:1) { (index) in
                        if index == 1 {
                            self.paymentInfo()
                        }
                    }

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
    private func applyJob() {
        
        self.view.showLoader()
        SEGAnalytics.shared().track(Analytics.appliedToJob)

        DataManager.shared.initiateForApply(jobId: self.jobId) { (conflictId, _, message, error) in
            self.view.hideLoader()
            if error == nil {
                if conflictId == nil {
                    TopMessage.shared.showMessageWithText(text: message ?? "", completion: nil)
                    if self.completion != nil {
                        self.completion!(JobConfirmStatus.pending, 1)
                    }
                    self.moveBack()
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
    
    private func changejobStatus(jobId:Int, status:Int) { // Start and complete jobs
        self.view.showLoader()
        let jobAction = (status == 3) ? Analytics.startedJob : Analytics.completedJob
        SEGAnalytics.shared().track(jobAction)

        DataManager.shared.changeJobStatus(jobId: jobId, status: status) { (_, message, error) in
            self.view.hideLoader()
            if error == nil {
                if self.completion != nil {
                    self.completion!((status == 3) ? .startCandidate : .completed, 1 )
                }
                TopMessage.shared.showMessageWithText(text: message ?? "", completion: nil)
                self.moveBack()
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
    
    private func cancelJob() {
        self.view.showLoader()
        
       let job = jobDetail
        
        SEGAnalytics.shared().track(Analytics.cancelledJob, properties: [AnalyticsPorperties.jobId:job?.id, AnalyticsPorperties.wagePerHour:job?.wagePerHour, AnalyticsPorperties.currency:"USD",AnalyticsPorperties.category:job?.parentCategoryName , AnalyticsPorperties.subCategory:job?.categoryName , AnalyticsPorperties.duration:job?.duration, AnalyticsPorperties.jobStartTime:job?.jobStartTime,  AnalyticsPorperties.jobEndTime:job?.jobEndTime, AnalyticsPorperties.distanceFromEmployee:job?.distance])
        
        DataManager.shared.cancelMyJob(jobId: self.jobId) { (_, message, error) in
            self.view.hideLoader()
            if error == nil {
                if self.completion != nil {
                    self.completion!(JobConfirmStatus.cancelled, 0)
                }
                self.moveBack()
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
}
