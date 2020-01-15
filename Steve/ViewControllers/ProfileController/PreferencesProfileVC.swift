//
//  PreferencesProfileVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 15/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics
class PreferencesProfileVC: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var preferenceTable: UITableView!
    
    // Variables
    var isExpanded:Bool = false
    var selectedSection = -1
    var profileData:CreateProfile?
    var categoryData:[Preferences]?
    var selectedIds:[Int] = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        SEGAnalytics.shared().track(Analytics.loadedAPpage)
//        SEGAnalytics.shared().track(Analytics.loadedAscreen)
        SEGAnalytics.shared().screen(AnalyticsScreens.Preferences)

        self.setupUI()
        self.getCategoryList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Custom Method
    private func setupUI() {
        self.preferenceTable.register(PreferenceCell.nib, forCellReuseIdentifier: CellIdentifier.preferenceCell.value)
        self.preferenceTable.register(UINib(nibName: ViewIdentifier.preferencesSection.value, bundle: nil), forHeaderFooterViewReuseIdentifier: ViewIdentifier.preferencesSection.value)
    }
    
    private func setupData() {
        profileList.category = self.selectedIds
    }
    
    // MARK: - IBActions
    @IBAction func nextClicked() {
        if self.selectedIds.count == 0 {
            TopMessage.shared.showMessageWithText(text: ValidationMessages.categoryMessage, completion: nil)
            return
        }
        self.setupData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.moveNext.value), object: nil)
    }
}

extension PreferencesProfileVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.categoryData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedSection > -1 && section == self.selectedSection {
            return self.categoryData?[self.selectedSection].subCategories?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: PreferenceCell.identifier, for: indexPath) as? PreferenceCell {
//            let subCategory = self.categoryData?[indexPath.section].subCategories?[indexPath.row]
            cell.configureData(self.categoryData?[indexPath.section].subCategories?[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var category = self.categoryData?[indexPath.section]
        let subCategory = category?.subCategories?[indexPath.row]
        let isCellSelected = self.categoryData?[indexPath.section].subCategories?[indexPath.row].isJobSelected ?? false
        if let cell = tableView.cellForRow(at: indexPath) as? PreferenceCell {
            if isCellSelected {
                cell.setJobSelected(false)
                if self.selectedIds.contains(subCategory?.id ?? -1) {
                    var isMakeCategorySelected = false
                    for job in category!.subCategories! {
                        if job.id == subCategory!.id {
                            self.categoryData?[indexPath.section].subCategories?[indexPath.row].isJobSelected = false
                            if let index = self.selectedIds.index(of: job.id!) {
                                self.selectedIds.remove(at: index)
                            }
                        } else if job.isJobSelected == true {
                            isMakeCategorySelected = true
                        }
                    }
                    self.makeSectionSelected(section: indexPath.section, isMakeCategorySelected)
                }
            } else {
                cell.setJobSelected(true)
//                if let _ = category {
//                    self.categoryData?[indexPath.section].isCategorySelected = true
//                }
                if let _ = subCategory {
                    self.categoryData?[indexPath.section].subCategories?[indexPath.row].isJobSelected = true
                    self.selectedIds.append(subCategory!.id!)
                }
                self.makeSectionSelected(section: indexPath.section, true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = (tableView.dequeueReusableHeaderFooterView(withIdentifier: ViewIdentifier.preferencesSection.value) as! PreferencesSection)  //PreferencesSection.section(tag: section)
        view.decorateSection(section:section, true)
        view.arrowImageView.rotate((self.selectedSection == section) ? (self.isExpanded ? .pi : 0.0) : 0.0)
        let isSelected = self.categoryData?[section].isCategorySelected ?? false
        if isSelected {
            view.setSelected(true)
        } else {
            view.setSelected()
        }
        view.setupData(title: self.categoryData?[section].name, image: self.categoryData?[section].image)
        view.completion = { [unowned self](tag) in
            if self.isExpanded {
                var previousSelection = -1
                if self.selectedSection > -1 {
                    previousSelection = self.selectedSection
                    self.collapseSection(self.selectedSection)
                    //view.arrowImageView.rotate(0.0)
                }
                if self.selectedSection != tag && tag != previousSelection {
                    view.arrowImageView.rotate(.pi)
                    self.expandSection(tag)
                    return
                }
            } else {
                self.expandSection(tag)
                view.arrowImageView.rotate(.pi)
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 69
    }
    
    func expandSection(_ section:Int) {
        self.isExpanded = true
        self.selectedSection = section
        var indexPaths:[IndexPath] = []
        for i in 0..<(self.categoryData?[section].subCategories?.count ?? 0) {
            let indexPath = IndexPath(row: i, section: section)
            indexPaths.append(indexPath)
        }
        if indexPaths.count > 0 {
            self.preferenceTable.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    func collapseSection(_ section:Int) {
        self.selectedSection = -1
        if let headerView = self.preferenceTable.headerView(forSection: section) as? PreferencesSection {
            headerView.arrowImageView.rotate(0.0)
        }
        var indexPaths:[IndexPath] = []
        for i in 0..<(self.categoryData?[section].subCategories?.count ?? 0) {
            let indexPath = IndexPath(row: i, section: section)
            indexPaths.append(indexPath)
        }
        if indexPaths.count > 0 {
            self.preferenceTable.deleteRows(at: indexPaths, with: .fade)
        }
        //self.preferenceTable.reloadData()
        self.isExpanded = false
    }
    
    func makeSectionSelected(section: Int, _ isSelected:Bool = false) {
        if self.categoryData?[section].isCategorySelected != isSelected {
            self.categoryData?[section].isCategorySelected = isSelected
            self.preferenceTable.beginUpdates()
            self.preferenceTable.reloadSections([section], with: .automatic)
            self.preferenceTable.endUpdates()
        }
    }
}

extension PreferencesProfileVC {
    // MARK: - Web services
    func getCategoryList() {
        self.view.showLoader()
        DataManager.shared.getCategory { (lists, _, error) in
            self.view.hideLoader()
            if error == nil {
                guard let category = lists else { return }
                self.categoryData = category
                self.preferenceTable.reloadData()
            } else {
                // Show error
                
            }
        }
    }
}
