//
//  WorkHistoryVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 25/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics

class WorkHistoryVC: UIViewController {

    // IBOutlets
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var workTable: UITableView!
    
    // Variables
    var histories:[WorkHistories]? // = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        SEGAnalytics.shared().track(Analytics.loadedAPpage)
//        SEGAnalytics.shared().track(Analytics.loadedAscreen)
        SEGAnalytics.shared().screen(AnalyticsScreens.WorkHistoryVC)

        self.setupUI()
        //if histories?.count ?? 0 <= 0 {
            showMyProfile()
        //}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Method
    private func setupNavigationBar() {
        self.topView.setHeaderData(title: NavTitle.workHistory, leftButtonImage: AppImage.backButton, rightButtonImage: AppImage.plusButton)
        self.topView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.topView.delegate = self
    }
    
    private func setupUI() {
        self.setupNavigationBar()
        self.workTable.register(WorkCell.nib, forCellReuseIdentifier: CellIdentifier.workCell.value)
        NotificationCenter.default.addObserver(self, selector: #selector(resetWorkHistory), name: NSNotification.Name(rawValue: NotificationName.appendUserHistory.value), object: nil)
    }
    
    private func takeAction(_ index:IndexPath, action:Int) {
        switch action {
        case 1:
            self.editHistory(index)
        case 2:
            self.deleteHistory(index)
        default:
            break
        }
    }
    
    private func deleteHistory(_ indexPath: IndexPath) {
        AlertView.showAlertWithMessage("",AppText.deleteWorkHistory, buttons: ["Delete"], coloredIndex: 0) { (index) in
            if index == 0 {
                self.histories?.remove(at: indexPath.row)
                self.workTable.reloadData()
            }
        }
        // call api for delete
    }
    
    private func editHistory(_ indexPath: IndexPath) {
        // open view to edit
        self.openAddEditView(true, indexPath.row)
    }
    
    private func openAddEditView(_ isEdit:Bool = false, _ index:Int = -1) {
        let vc = UIStoryboard.navigateToAddWorkHistoryVC()
        if isEdit {
            vc.isEditActive = isEdit
            vc.name = self.histories?[index].employerName ?? ""
            vc.email = self.histories?[index].employerEmail ?? ""
        }
//        vc.completion = { [unowned self] (data) in
//            if self.histories.count > 0 {
//                self.histories.removeAll()
//            }
//            self.histories = data
//            self.workTable.reloadData()
//        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func resetWorkHistory(notification:NSNotification) {
        if let userData = notification.object as? User {
            if (self.histories?.count ?? 0) > 0 {
                self.histories?.removeAll()
            }
            self.histories = userData.userWorkHistory ?? []
            self.workTable.reloadData()
        }
    }
}

extension WorkHistoryVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.histories?.count ?? 0) == 0 {
            self.workTable.setEmptyMessage("No Work History Found")
        } else {
            self.workTable.restore()
        }
        return self.histories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: WorkCell.identifier, for: indexPath) as? WorkCell {
            cell.decorateCellView()
            cell.configureData(data: self.histories![indexPath.row], indexPath.row)
            cell.completion = { [unowned self] (actionType) in
                self.takeAction(indexPath, action: actionType)
            }
            return cell
        }
        return UITableViewCell()
    }
}

extension WorkHistoryVC: TopBarViewDelegate {
    // MARK: - TopView Delegate
    func didTapLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapRightButton(_ btn: UIButton?) {
        self.openAddEditView()
    }
}

extension WorkHistoryVC {
    // MARK: - Web Services
    private func showMyProfile() {
        self.view.showLoader()
        DataManager.shared.showProfile { (userData, _, error, status) in
            self.view.hideLoader()
            if error == nil {
                self.histories = userData?.userWorkHistory;
                self.workTable.reloadData()
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
}
