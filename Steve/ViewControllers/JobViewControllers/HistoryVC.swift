//
//  HistoryVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 25/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics
class HistoryVC: UIViewController {

    // IBOutlets
    @IBOutlet var tabViews: [UIButton]!
    @IBOutlet var jobTableView: UITableView!
    
    // Variables
    var selectedIndex:Int = 1
    var selectedCellIndex:Int = -1
    var jobs:[Job] = []
    
    private var currentPage = 1
    private var totalPages = 1
    private let refreshControl = UIRefreshControl()
    private var isPulledToRefresh: Bool = false
    private var isRequestSent = false;
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //SEGAnalytics.shared().track(Analytics.loadedAPpage)
        SEGAnalytics.shared().screen(AnalyticsScreens.historyVC)

        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: NotificationName.refreshData.value), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetHistoryData), name: NSNotification.Name(rawValue: NotificationName.resetHistory.value), object: nil)
        
        
        
        self.setupData()
        self.setupTabView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Method
    private func setupTabView() {
        self.tabSelectionAction(button: self.tabViews[0])
    }
    
    private func setupData() {
        self.jobTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.handlePullToRefresh), for: UIControlEvents.valueChanged)
        self.loadNextPage()
        //self.loadJobData()
    }
    
    @objc func resetHistoryData(notif:Notification) {
        self.clearAll()
        self.jobTableView.dataSource = self
        self.jobTableView.delegate = self
        if isRequestSent == false {
            isRequestSent = true
        self.loadJobData()
        }
    }
    
    @objc func handlePullToRefresh() {
        isPulledToRefresh = true
        self.currentPage = 1
        self.totalPages = 1
        self.view.isUserInteractionEnabled = false
        self.loadJobData(true)
    }
    
    @objc func refreshData(notif:NSNotification) {
        //self.handlePullToRefresh()
        if let type = notif.object as? Int {
            switch type {
            case 2...5:
                self.view.makeToast(message: AppText.refreshScreen)
            default:
                break
            }
        }
    }
    
    private func clearAll() {
        self.jobs.removeAll()
        self.currentPage = 1
        self.totalPages = 1
        self.jobTableView.dataSource = nil
        self.jobTableView.delegate = nil
        self.jobTableView.reloadData()
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
                    self.loadJobData(true)
                } else {
                    self.jobTableView.infiniteScrollingView.stopAnimating()
                }
            } else {
                self.jobTableView.infiniteScrollingView.stopAnimating()
            }
        }
    }
    
    // API called according to status
    private func checkStatusAndProceed(_ index: Int) {
        self.selectedCellIndex = index
        let currentStatus = self.jobs[index].status
        switch currentStatus {
        case 2:
            self.changejobStatus(jobId:self.jobs[index].id ?? 0, status: JobConfirmStatus.startCandidate.rawValue)
            let job = self.jobs[index]
            SEGAnalytics.shared().track(Analytics.startedJob, properties: [AnalyticsPorperties.jobId:job.id, AnalyticsPorperties.wagePerHour:job.wagePerHour, AnalyticsPorperties.currency:"USD",AnalyticsPorperties.category:job.parentCategoryName , AnalyticsPorperties.subCategory:job.categoryName , AnalyticsPorperties.duration:job.duration, AnalyticsPorperties.jobStartTime:job.jobStartTime,  AnalyticsPorperties.jobEndTime:job.jobEndTime, AnalyticsPorperties.distanceFromEmployee:job.distance])
        case 4:
            //self.changejobStatus(jobId:self.jobs[index].id ?? 0, status: JobConfirmStatus.completed.rawValue)
            self.changejobStatus(jobId:self.jobs[index].id ?? 0, status: JobConfirmStatus.pendingForApproval.rawValue)
            let job  = self.jobs[index]
            SEGAnalytics.shared().track(Analytics.completedJob, properties: [AnalyticsPorperties.jobId:job.id, AnalyticsPorperties.wagePerHour:job.wagePerHour, AnalyticsPorperties.currency:"USD",AnalyticsPorperties.category:job.parentCategoryName , AnalyticsPorperties.subCategory:job.categoryName , AnalyticsPorperties.duration:job.duration, AnalyticsPorperties.jobStartTime:job.jobStartTime,  AnalyticsPorperties.jobEndTime:job.jobEndTime, AnalyticsPorperties.distanceFromEmployee:job.distance])
        default:
            break
        }
    }
    
    private func updateCell(at index:Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.jobTableView.reloadRows(at: [indexPath], with: .fade)
        self.selectedCellIndex = -1
    }
    
    // MARK: - IBActions
    @IBAction func tabSelectionAction(button:UIButton) {
        self.selectedIndex = button.tag-100
        self.clearAll()
        for tab in tabViews {
            if tab.tag == button.tag {
                tab.superview?.backgroundColor = CustomColor.profileSelectedTextColor
                tab.titleLabel?.font = UIFont(name: Font.MontserratSemiBold, size: 12)
                tab.setTitleColor(CustomColor.tabSelectedColor, for: .normal)
            } else {
                tab.superview?.backgroundColor = .white
                tab.titleLabel?.font = UIFont(name: Font.MontserratRegular, size: 12)
                tab.setTitleColor(CustomColor.tabDefaultColor, for: .normal)
            }
        }
        self.jobTableView.dataSource = self
        self.jobTableView.delegate = self
        
            self.loadJobData();
       // }
    }
}

extension HistoryVC: UITableViewDataSource, UITableViewDelegate {
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
            cell = JobCell.jobCell()
            cell?.jobCompletion = { [unowned self] (index) in
                self.checkStatusAndProceed(index)
            }
        }
        cell?.setupData(job:self.jobs[indexPath.row],index:indexPath)
        return cell!
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.jobTableView.deselectRow(at: indexPath, animated: true)
        let vc = UIStoryboard.navigateToJobDetailVC()
        vc.jobId = self.jobs[indexPath.row].id ?? 0
        vc.completion = { [weak self] (jobStatus, isApplied) in
            if jobStatus == JobConfirmStatus.cancelledByEmployer {
                self?.jobs.remove(at: indexPath.row)
                self?.jobTableView.deleteRows(at: [indexPath], with: .fade)
                self?.jobTableView.reloadData()
            } else {
                if self?.selectedIndex == 1 {
                    self?.handleAppliedJobs(jobStatus: jobStatus, isApplied: isApplied, indexPath: indexPath)
                } else if self?.selectedIndex == 2 {
                    self?.handleOngoingJobs(jobStatus: jobStatus, isApplied: isApplied, indexPath: indexPath)
                }
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleAppliedJobs(jobStatus:JobConfirmStatus, isApplied:Int, indexPath:IndexPath) {
        if jobStatus.rawValue !=  self.jobs[indexPath.row].status {
            if jobStatus.rawValue < 2 && isApplied == 1 {
                self.jobs[indexPath.row].status = jobStatus.rawValue
                self.jobTableView.reloadRows(at: [indexPath], with: .fade)
            } else {
                self.jobs.remove(at: indexPath.row)
                self.jobTableView.deleteRows(at: [indexPath], with: .fade)
                self.jobTableView.reloadData()
            }
        }
    }
    
    private func handleOngoingJobs(jobStatus:JobConfirmStatus, isApplied:Int, indexPath:IndexPath) {
        if jobStatus == JobConfirmStatus.startCandidate {
            self.jobs[indexPath.row].status = jobStatus.rawValue
            self.jobTableView.reloadRows(at: [indexPath], with: .fade)
        } else if jobStatus == JobConfirmStatus.completed {
            self.jobs.remove(at: indexPath.row)
            self.jobTableView.deleteRows(at: [indexPath], with: .fade)
            self.jobTableView.reloadData()
        } else if jobStatus == JobConfirmStatus.cancelled {
            
            let job = self.jobs[indexPath.row]
            SEGAnalytics.shared().track(Analytics.cancelledJob, properties: [AnalyticsPorperties.jobId:job.id, AnalyticsPorperties.wagePerHour:job.wagePerHour, AnalyticsPorperties.currency:"USD",AnalyticsPorperties.category:job.parentCategoryName , AnalyticsPorperties.subCategory:job.categoryName , AnalyticsPorperties.duration:job.duration, AnalyticsPorperties.jobStartTime:job.jobStartTime,  AnalyticsPorperties.jobEndTime:job.jobEndTime, AnalyticsPorperties.distanceFromEmployee:job.distance])
            
            self.jobs.remove(at: indexPath.row)
            self.jobTableView.deleteRows(at: [indexPath], with: .fade)
            self.jobTableView.reloadData()
        } else if jobStatus.rawValue !=  self.jobs[indexPath.row].status {
            self.jobs[indexPath.row].status = jobStatus.rawValue
            self.jobTableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
}

extension HistoryVC {
    // MARK: - Web Services
    private func loadJobData(_ isLoadingMore:Bool = false) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if isLoadingMore == false { // load first time, then show loader
            //self.view.showLoader()
            self.jobs.removeAll()
            //}
        }
        
        
        for _ in 0...10 {
            let job = Job.init(id: 1, userId: 1, jobName: "Teacher Class", description: "Teaching" , categoryId: 1, wagePerHour: "11", jobStartTime: "10:11pm", jobEndTime: "11:00Pm", duration: "1 Hour", address: "Hsr Layout Banglore", latitude: 1.1, longitude: 2.1, status: 2, useName: "use Name", categoryName: "Category Name", categoryImageUrl: "http://www.google.com", parentCategoryName: "parentCategoryName", parentCategoryId: 1, distance: 2.2, isApplied: 1, employerPhoneNumber: "employerPhoneNumber", employerAddress: "employerAddress", employerWebsite: "www.google.com")
            
            self.jobs.append(job);
        }
        jobTableView.reloadData()
        
//        DataManager.shared.getMyJobs(key: self.selectedIndex, page:self.currentPage) { (jobs, _, error, status, currentPage, totalPage) in
//            self.isRequestSent = false
//            if isLoadingMore == false {
//                self.view.hideLoader()
//            } else {
//                self.jobTableView.infiniteScrollingView.stopAnimating()
//            }
//            if self.isPulledToRefresh == true {
//                self.clearAll()
//                self.refreshControl.endRefreshing()
//                self.view.isUserInteractionEnabled = true
//                self.isPulledToRefresh = false
//                self.jobTableView.delegate = self
//                self.jobTableView.dataSource = self
//            }
//            if error == nil {
//                self.currentPage = currentPage
//                self.totalPages = totalPage
//                self.jobs.append(contentsOf: jobs ?? [])
//                self.jobTableView.reloadData()
//            } else {
//                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
//            }
//        }
    }
    
    private func changejobStatus(jobId:Int, status:Int) { // Start and complete jobs
        self.view.showLoader()
        let jobAction = (status == 3) ? Analytics.startedJob : Analytics.completedJob
        //SEGAnalytics.shared().track(jobAction)
        DataManager.shared.changeJobStatus(jobId: jobId, status: status) { (_, message, error) in
            self.view.hideLoader()
            if error == nil {
                TopMessage.shared.showMessageWithText(text: message ?? "", completion: nil)
                self.jobs[self.selectedCellIndex].status = status
                if status == 5 {
                    self.jobs.remove(at: self.selectedCellIndex)
                    let indexPath = IndexPath(row: self.selectedCellIndex, section: 0)
                    self.jobTableView.deleteRows(at: [indexPath], with: .fade)
                    self.jobTableView.reloadData()
                } else {
                    self.updateCell(at: self.selectedCellIndex)
                }
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
}
