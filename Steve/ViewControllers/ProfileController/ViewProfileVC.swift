//
//  ViewProfileVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 04/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics

class ViewProfileVC: UIViewController {
    // IBOutlets
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var profileTable: UITableView!
    
    // Variables
    private var header = ViewProfileHeader.viewHeader()
    private var user:User?
    private var tableData:[[String:String]] = [[:]]
    private var docCellIdentifier = "DocumentCell"
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        SEGAnalytics.shared().screen(AnalyticsScreens.ViewProfileVC)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDetails), name: NSNotification.Name(rawValue: NotificationName.refreshUserDetail.value), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetWorkHistory), name: NSNotification.Name(rawValue: NotificationName.appendUserHistory.value), object: nil)
        self.setTopView()
        self.setupUI()
        self.showMyProfile()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Method
    private func setTopView() {
        self.topView.setHeaderData(title: NavTitle.myProfile, leftButtonImage: AppImage.setting)
        self.topView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.topView.delegate = self
    }
    
    private func setupUI() {
        self.profileTable.register(JobDetailCell.nib, forCellReuseIdentifier: "JobDetailCell")
        self.profileTable.register(CategoryCell.nib, forCellReuseIdentifier: "CategoryCell")
        self.profileTable.register(WorkViewCell.nib, forCellReuseIdentifier: "WorkViewCell")
        let nib = UINib(nibName: "DocumentCell", bundle: nil)
        self.profileTable.register(nib, forCellReuseIdentifier: docCellIdentifier)
        self.profileTable.rowHeight = UITableViewAutomaticDimension
        self.profileTable.estimatedRowHeight = 76
        self.header.editComplition = { [weak self] in
            self?.editClicked()
        }
        self.profileTable.tableHeaderView = header
    }
    
    
    private func setupData() {
        // self.user?.youtubeLink = "https://www.youtube.com/watch?v=svsHdrJ62Y8"//"https://www.youtube.com/watch?v=TIE921```````````mUvSsw"
        self.header.configureHeader(userData: self.user)
        self.tableData = [
            ["title":"Short Bio:", "value":self.user?.bio ?? ""],
            //["title":"Preferred Category:", "value":""],
            //["title":"My Address and Working Radius", "value":(self.user?.address ?? "") + ", " + "\(self.user?.defaultRadius ?? 50)km"]
        ]
        
        if (self.user?.youtubeLink ?? "").count > 0 {
            self.tableData.insert(["title":"youtubeLink:", "value":self.user?.youtubeLink ?? ""], at:1)
            //self.tableData.insert(["title":"Work History:", "value":""], at: 2)
        }
        self.tableData.append(["title":"Qualifications:", "value":self.user?.qualification ?? ""])
        let isWorkHistoryAvailable = ((self.user?.userWorkHistory?.count ?? 0) > 0) ? true : false
        
        if user?.userDocuments?.count ?? 0 > 0 {
            self.tableData.append(["title":"Document:", "value":""])
        }
        self.tableData.append(["title":"Work Experience:", "value":self.user?.workExperience ?? ""])
        self.tableData.append(["title":"Preferred Category:", "value":""]);
        self.tableData.append(["title":"My Address and Working Radius", "value":(self.user?.address ?? "") + ", " + "\(self.user?.defaultRadius ?? 50)km"]);
        
        if isWorkHistoryAvailable {
            //self.tableData.insert(["title":"Work History:", "value":""], at: 3)
            self.tableData.append(["title":"Work History:", "value":""])
        }
        
        self.profileTable.reloadData()
    }
    
    private func editClicked() {
        let vc = UIStoryboard.navigateToEditProfileVC()
        vc.user = self.user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openCategoryVC() {
        let vc = UIStoryboard.navigateToCategoryVC()
        if let category = self.user?.userCategories {
            vc.selectedIds = category.map {$0.categoryId!}
        }
        vc.isViewOnly = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openYoutubeLink() {
        guard let youtubeURL = self.user?.youtubeLink else {
            return
        }
        var newURL:String = ""
        if youtubeURL.hasPrefix("http") {
            newURL = youtubeURL.components(separatedBy: "//").last ?? ""
        }
        
        var newAppURL = URL(string:"youtube://\(newURL)")!
        if !UIApplication.shared.canOpenURL(newAppURL)  {
            newAppURL = URL(string:"\(youtubeURL)")!
        }
        UIApplication.shared.open(newAppURL, options: [:], completionHandler: nil)
    }
    
    private func saveData(user:User) {
        
        var documents:[[String:String]] = []
        //var docPrams =
        for doc in user.userDocuments ?? [] {
            if doc.image != nil {
                let params  = ["docType":"\(doc.docType!)"  , "image":doc.image ,"imageUrl":doc.imageUrl]
                if params is [String : String] {
                    documents.append(params as! [String : String]);
                }
            }
        }
        UserManager.shared.saveUserUploadedDoc(docs: documents);
    }

    
    // MARK: - Notification Methods
    @objc func refreshDetails(notification:NSNotification) {
        self.showMyProfile()
    }
    
    @objc func resetWorkHistory(notification:NSNotification) {
        if let userData = notification.object as? User {
            self.user = userData
            self.setupData()
        }
    }
}

extension ViewProfileVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.tableData[indexPath.row]["title"] ?? "").hasPrefix("Work History") {
            if let cell = tableView.dequeueReusableCell(withIdentifier: WorkViewCell.identifier, for: indexPath) as? WorkViewCell {
                cell.setupData(self.tableData[indexPath.row],history:self.user?.userWorkHistory ?? [], isLastCell: (indexPath.row == self.tableData.count - 1) ? true : false, index: indexPath.row)
                return cell
            }
        } else if (self.tableData[indexPath.row]["title"] ?? "").hasPrefix("Preferred Category") {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell {
                cell.setupData(self.tableData[indexPath.row]["title"], self.user?.userCategories ?? [],isLastCell: (indexPath.row == self.tableData.count - 1) ? true : false, index: indexPath.row)
                cell.completion = { [weak self] in
                    self?.openCategoryVC()
                }
                return cell
            }
        }
            
            
        else if (self.tableData[indexPath.row]["title"] ?? "").hasPrefix("Document") {
            if let cell = tableView.dequeueReusableCell(withIdentifier: docCellIdentifier, for: indexPath) as? DocumentCell {
                cell.docs = user?.userDocuments
                cell.setupData(index: indexPath.row)
                return cell
            }
            
        } else /*if indexPath.row != 4*/ {
            if let cell = tableView.dequeueReusableCell(withIdentifier: JobDetailCell.identifier, for: indexPath) as? JobDetailCell {
                cell.setupData(self.tableData[indexPath.row],isLastCell: (indexPath.row == self.tableData.count - 1) ? true : false, index: indexPath.row)
                cell.completion = { [weak self] in
                    self?.openYoutubeLink()
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.tableData[indexPath.row]["title"] ?? "").hasPrefix("Work History") {
            return CGFloat(((self.user?.userWorkHistory?.count ?? 1) * 44) + 30)
        }
        return UITableViewAutomaticDimension
    }
}

extension ViewProfileVC:TopBarViewDelegate {
    // MARK: - TopView Delegate
    func didTapLeftButton() {
        let vc = UIStoryboard.navigateToSettingVC()
        vc.profile = self.user
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewProfileVC {
    // MARK: - Web Services
    private func showMyProfile() {
        //self.view.showLoader()
        self.user = UserManager.shared.activeUser
        self.setupData();
        
//        DataManager.shared.showProfile { (userData, _, error, status) in
//            self.view.hideLoader()
//            if error == nil {
//                self.user = userData
//                self.setupData()
//                self.saveData(user: userData!)
//            } else {
//                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
//            }
//        }
        
        
        
    }
}
