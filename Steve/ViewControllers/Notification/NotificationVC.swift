//
//  NotificationVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 11/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics

class NotificationVC: UIViewController {

    // IBOutlets
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var notificationTableView: UITableView!
    
    // Variables
    var notifications:[NotificationData] = []
    var currentPage = 1
    var totalPages = 1
    let refreshControl = UIRefreshControl()
    var isPulledToRefresh: Bool = false
    
    // MARK: - Life Cycle
    override func viewDidLoad(){
        super.viewDidLoad()
        SEGAnalytics.shared().screen(AnalyticsScreens.NotificationVC)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadNewNotification), name: NSNotification.Name(rawValue: NotificationName.newNotification.value), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadUpdatedNofitication), name: NSNotification.Name(rawValue: NotificationName.resetNotification.value), object: nil)
        self.setupUI()
        self.setupData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Method
    private func setupUI() {
        self.topView.setHeaderData(title: NavTitle.notifications)
        self.topView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.notificationTableView.rowHeight = UITableViewAutomaticDimension
        self.notificationTableView.estimatedRowHeight = 76
        self.notificationTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.handlePullToRefresh), for: UIControlEvents.valueChanged)
    }
    
    private func setupData() {
        self.notificationTableView.register(NotificationCell.nib, forCellReuseIdentifier: "NotificationCell")
        self.notificationTableView.dataSource = self
        self.notificationTableView.delegate = self
        self.loadNextPage()
        self.notificationsList()
        self.markAllNotificationAsRead()
    }
    
    private func loadNextPage() {
        self.notificationTableView.addInfiniteScrolling {
            if self.isPulledToRefresh {
                self.notificationTableView.infiniteScrollingView.stopAnimating()
                return
            }
            if self.notifications.count > 0 {
                if self.currentPage < self.totalPages {
                    self.currentPage = self.currentPage + 1
                    self.notificationsList(true)
                } else {
                    self.notificationTableView.infiniteScrollingView.stopAnimating()
                }
            } else {
                self.notificationTableView.infiniteScrollingView.stopAnimating()
            }
        }
    }
    
    private func clearAll() {
        self.notifications.removeAll()
        self.notificationTableView.dataSource = nil
        self.notificationTableView.delegate = nil
    }
    
    @objc func handlePullToRefresh() {
        isPulledToRefresh = true
        self.currentPage = 1
        self.totalPages = 1
        self.notificationsList(true)
        self.markAllNotificationAsRead()
    }
    
    @objc func reloadNewNotification(notification:NSNotification) {
        self.view.makeToast(message: AppText.newNotification)
    }
    
    @objc func loadUpdatedNofitication() {
        self.handlePullToRefresh()
    }
    
    private func openWorkHistory(userProfile:User) {
        let vc = UIStoryboard.navigateToWorkHistoryVC()
        vc.histories = userProfile.userWorkHistory
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension NotificationVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.notifications.count == 0 {
            self.notificationTableView.setEmptyMessage("No Notification Found")
        } else {
            self.notificationTableView.restore()
        }
        return self.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.identifier, for: indexPath) as? NotificationCell {
            cell.configureData(self.notifications[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.notifications[indexPath.row].isRead = 1
        self.notificationTableView.reloadRows(at: [indexPath], with: .fade)
        tableView.deselectRow(at: indexPath, animated: true)
        let type = self.notifications[indexPath.row].type ?? 0
        if type == 12 {
            showMyProfile();
        }
        else if type != 3 && type != 4 && type != 13{
            let vc = UIStoryboard.navigateToJobDetailVC()
            vc.jobId = self.notifications[indexPath.row].jobId ?? 0
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}

extension NotificationVC {
    // MARK: - Web Services
    private func notificationsList(_ isLoadingMore:Bool = false) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if isLoadingMore == false { // load first time, then show loader
            //self.view.showLoader()
        }
        
        
        for  _ in 0...10 {
            let notification = NotificationData.init(id: 1, jobId: 1, senderId: 1, recipientId: 1, type: 1, text: "Narender has requested for math classes", isRead: 0, createdAt: "11-11-2019", updatedAt: "12-11-19")
            self.notifications.append(notification)
            self.notificationTableView.reloadData()
            
        }
        
        /*
        DataManager.shared.getAllNotification(page: self.currentPage) { (result, _, error, status, current, last) in
            if isLoadingMore == false {
                self.view.hideLoader()
            } else {
                self.notificationTableView.infiniteScrollingView.stopAnimating()
            }
            if self.isPulledToRefresh == true {
                self.clearAll()
                self.refreshControl.endRefreshing()
                self.isPulledToRefresh = false
                self.notificationTableView.delegate = self
                self.notificationTableView.dataSource = self
            }
            if error == nil {
                if let list = result {
                    self.currentPage = current
                    self.totalPages = last
                    self.notifications.append(contentsOf: list)
                    self.notificationTableView.reloadData()
                }
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }*/
    }
    
    private func showMyProfile() {
        self.view.showLoader()
        DataManager.shared.showProfile { (userData, _, error, status) in
            self.view.hideLoader()
            if error == nil {
                if let userData = userData {
                    self.openWorkHistory(userProfile: userData);
                }
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
    
    @objc func markAllNotificationAsRead() {
        UIApplication.shared.applicationIconBadgeNumber = 0
//        DataManager.shared.setNotificationStatus {(_,_,error) in
//            DispatchQueue.main.async {
//                if error == nil {
//                    UIApplication.shared.applicationIconBadgeNumber = 0
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.badgeCount.value), object: false)
//                }
//            }
//        }
    }
}
