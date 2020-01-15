//
//  SettingVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 31/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import MessageUI
import Analytics

class SettingVC: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var settingTable: UITableView!
    
    // Variables
    var titles = ["I am available for jobs", "Work History","Payment Information", "Terms & Conditions", "Privacy Policy", "Onboarding Tutorials", "Contact App Admin"]
    var contact:ContactInfo?
    var user = UserManager.shared.activeUser
    var profile:User?
    var isGuestUser:Bool {
        return (self.user == nil) ? true : false
    }
    
    var isExpanded:Bool = false
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        SEGAnalytics.shared().track(Analytics.loadedAPpage)
        SEGAnalytics.shared().screen(AnalyticsScreens.SettingVc)

        self.setupUI()
        self.getAdminContactInfo()
        self.setupData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Custom Method
    private func setupUI() {
        self.topView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.topView.setHeaderData(title: NavTitle.settings, leftButtonImage: AppText.back)
        self.topView.delegate = self
        self.settingTable.rowHeight = UITableViewAutomaticDimension
        self.settingTable.estimatedRowHeight = 135
        self.settingTable.dataSource = self
        self.settingTable.delegate = self
    }
    
    private func setupData() {
        if self.user != nil {
            if (self.user?.facebookId?.count ?? 0) <= 0 {
                self.titles.insert("Change Password", at: 3)
            }
        }
        //        if !isGuestUser {
        //            titles.append("Log Out")
        //        }
        self.settingTable.reloadData()
    }
    
    private func tableAction(_ indexPath: IndexPath) {
        var indexRow = indexPath.row
        if (self.user?.facebookId?.count ?? 0) > 0 && indexPath.row > 2 {
            indexRow += 1
        }
        switch indexRow {
        case 1:
            self.openWorkHistory()
            break
        case 2:
            self.paymentInfo()
            break
        case 3:
            self.changePassword()
            break
        case 4:
            self.openTermsScreen()
            break
        case 5:
            self.openTermsScreen(true)
            break
        case 6:
            self.openOnboarding()
            break
        case 7:
            self.sendEmail()
            break
        default:
            break
        }
    }
    
    private func openWorkHistory() {
        let vc = UIStoryboard.navigateToWorkHistoryVC()
        vc.histories = self.profile?.userWorkHistory
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func paymentInfo() {
        let vc = UIStoryboard.navigateToAccountVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func changePassword() {
        let vc = UIStoryboard.navigateToChangePasswordVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openTermsScreen(_ isViewPolicy:Bool = false) {
        let vc = UIStoryboard.navigateToTermsAndPolicyVC()
        if isViewPolicy {
            vc.isViewTypePolicy = isViewPolicy
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openOnboarding() {
        let vc = UIStoryboard.navigateToOnboardingVC()
        vc.isViewOnly = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func expandContactCell(_ tableView: UITableView, indexPath: IndexPath) {
        self.isExpanded = !self.isExpanded
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    private func collapseContactCell() {
        self.isExpanded = !self.isExpanded
        let indexPath = IndexPath(row: 6, section: 0)
        self.settingTable.reloadRows(at: [indexPath], with: .fade)
    }
    
    private func contactAdmin(type:ContactBy) {
        switch type {
        case .email:
            self.sendEmail()
            break
        case .mobile:
            self.makeACall()
            break
        }
    }
    
    private func sendEmail() {
        let emailId = self.contact?.email ?? ""
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([emailId])
            //mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            TopMessage.shared.showMessageWithText(text: "Unable to open mail. Please try again.", completion: nil)
        }
    }
    
    private func makeACall() {
        let phone = self.contact?.phoneNumber ?? ""
        if phone == "" {
            TopMessage.shared.showMessageWithText(text: "Unable to make a call this time.", completion: nil)
            return
        }
        if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func logout() {
        if !isGuestUser {
            AlertView.showAlertWithMessage("Logout", "Are you sure you want to miss out on job opportunities?", buttons: ["Yes", "No"], hasBorder:true, coloredIndex:1) { (index) in
                if index == 0 {
                    //Utilities.logOutUser("")
                    SEGAnalytics.shared().track(Analytics.logoutCompleted)
                    self.logoutFromApp()
                }
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func logoutUser() {
        self.logout()
    }
}

extension SettingVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != (((self.user?.facebookId?.count ?? 0) > 0) ? 6 : 7) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as! SettingCell
            if indexPath.row == 0 {
                cell.configureCell(title: self.titles[indexPath.row], isVisbleSwitch: true)
                cell.completion = { [weak self] (isAvailable) in
                    self?.changeAvalabilityStatus(for: cell, isAvailable: isAvailable)
                }
            } else {
                cell.configureCell(title: self.titles[indexPath.row])
            }
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.contactCell.value) as? ContactCell
            if cell == nil {
                self.settingTable.register(UINib.init(nibName: CellIdentifier.contactCell.value, bundle: nil), forCellReuseIdentifier: CellIdentifier.contactCell.value)
                cell = ContactCell.contactCell()
            }
            
            let angle: CGFloat = self.isExpanded ? .pi / 2 : 0
            UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut, animations: {
                cell?.viewHeightConstraint.constant = self.isExpanded ? 85 : 0
                cell?.arrowImageView.transform = CGAffineTransform(rotationAngle: angle)
            })
            //            cell?.markSelected(self.isExpanded)
            //            cell?.arrowImageView.rotateArrow(self.isExpanded)
            cell?.configureCell(title: self.titles[indexPath.row])
            cell?.completion = { [weak self] (contact) in
                self?.contactAdmin(type: contact)
            }
            return cell!
        }
    }
    
    // MARK: - Table Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        if indexPath.row == (((self.user?.facebookId?.count ?? 0) > 0) ? 6 : 7) {
//            self.expandContactCell(tableView, indexPath:indexPath)
//        } else {
//            if isExpanded { self.collapseContactCell() }
//            self.tableAction(indexPath)
//        }
         self.tableAction(indexPath)
    }
}

extension SettingVC: TopBarViewDelegate {
    func didTapLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SettingVC:MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        var message = ""
        switch result {
        case .cancelled:
            message = "Mail cancelled."
        case .failed:
            message = "Mail send fail."
        case .sent:
            message = "Mail sent."
        default:
            break
        }
        TopMessage.shared.showMessageWithText(text: message, completion: nil)
    }
}

extension SettingVC {
    // MARK: - Web Services
    private func getAdminContactInfo() {
        self.view.showLoader()
        DataManager.shared.contactInfo { (info, _, error, status) in
            self.view.hideLoader()
            if error == nil {
                self.contact = info
            }
        }
    }
    
    private func changeAvalabilityStatus(for cell: SettingCell, isAvailable:Bool = false) {
        self.view.showLoader()
        DataManager.shared.markAvailability(isAvailable: isAvailable) { (_, message, error) in
            self.view.hideLoader()
            if error == nil {
                self.user!.isAvailable = isAvailable ? 1 : 0
                UserManager.shared.activeUser = self.user
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
                cell.settingSwitch.isOn = isAvailable ? false : true
            }
        }
    }
    
    private func logoutFromApp() {
        self.view.showLoader()
        DataManager.shared.logout { (_, message, error) in
            self.view.hideLoader()
            if error == nil {
                TopMessage.shared.showMessageWithText(text: "Logout successfully.", completion: nil)
                Utilities.logOutUser("")
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
}
