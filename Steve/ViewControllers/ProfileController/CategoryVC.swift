//
//  CategoryVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 06/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Analytics

class CategoryVC: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var saveButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButtonBottomConstraint: NSLayoutConstraint!
    
    // Variables
    var isExpanded:Bool = false
    var selectedSection = -1
    var categoryData:[Preferences]?
    var selectedIds:[Int] = []
    var isViewOnly:Bool = false
    
    var complition:(([Int])->Void)?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        SEGAnalytics.shared().track(Analytics.loadedAPpage)
//        SEGAnalytics.shared().track(Analytics.loadedAscreen)
        SEGAnalytics.shared().screen(AnalyticsScreens.CategoryVC)
        self.setupTopView()
        self.setupUI()
        self.getCategoryList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Custom Method
    private func setupTopView() {
        if self.isViewOnly {
            self.topView.setHeaderData(title: NavTitle.categories, leftButtonImage: AppImage.backButton)
        } else {
            self.topView.setHeaderData(title: NavTitle.editCategory, leftButtonImage: AppImage.backButton)
        }
        self.topView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.topView.delegate = self
    }
    
    private func setupUI() {
        self.categoryTableView.register(PreferenceCell.nib, forCellReuseIdentifier: CellIdentifier.preferenceCell.value)
        self.categoryTableView.register(UINib(nibName: ViewIdentifier.preferencesSection.value, bundle: nil), forHeaderFooterViewReuseIdentifier: ViewIdentifier.preferencesSection.value)
        if self.isViewOnly {
            self.categoryTableView.allowsSelection = false
            self.saveButtonHeightConstraint.constant = 0
            self.saveButtonHeightConstraint.constant = -60
            self.saveButton.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupData() {
        self.categoryTableView.reloadData()
        self.markSelectedCategory()
    }
    
    private func markSelectedCategory() {
        guard let categories = self.categoryData else {
            return
        }
        var catCount = 0
        var subCatCount = 0
        for cat in categories {
            for subCat in cat.subCategories! {
                if self.selectedIds.contains(subCat.id ?? 0) {
                    //categories[catCount].subCategories![subCatCount].isJobSelected = true
                    self.makeSectionSelected(section: catCount, true)
                }
                subCatCount += 1
            }
            catCount += 1
            subCatCount = 0
        }
    }
    
    // MARK: - IBActions
    @IBAction func saveClicked() {
        if self.selectedIds.count == 0 {
            TopMessage.shared.showMessageWithText(text: ValidationMessages.categoryMessage, completion: nil)
            return
        }
        
        if self.complition != nil {
            self.complition!(self.selectedIds)
        }
        
        var categories:[String] = []
        
        for cat in self.categoryData ?? [] {
            if cat.isCategorySelected == true {
                categories.append(cat.name ?? "")
            }
        }
        
         SEGAnalytics.shared().track(Analytics.onboardingJobCategoryPreferences, properties: [AnalyticsPorperties.preferredJobCategories:categories ])
        self.navigationController?.popViewController(animated: true)
    }
}

extension CategoryVC:UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table Datasource
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
            let subcategory = self.categoryData?[indexPath.section].subCategories?[indexPath.row]
            let selected = self.selectedIds.contains(subcategory?.id ?? 0)
            if selected {
                self.categoryData?[indexPath.section].subCategories?[indexPath.row].isJobSelected = true
            } else {
                self.categoryData?[indexPath.section].subCategories?[indexPath.row].isJobSelected = false
            }
            cell.configureEditData(subcategory,isSelected: selected)
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
                if let _ = subCategory {
                    self.categoryData?[indexPath.section].subCategories?[indexPath.row].isJobSelected = true
                    self.selectedIds.append(subCategory!.id!)
                }
                self.makeSectionSelected(section: indexPath.section, true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ViewIdentifier.preferencesSection.value) as! PreferencesSection //PreferencesSection.section(tag: section)
        view.decorateSection(section:section, true)
        //let view = PreferencesSection.section(tag: section, true)
        let isSelected = self.categoryData?[section].isCategorySelected ?? false
        view.setSelected(isSelected)
        view.arrowImageView.rotate((self.selectedSection == section) ? (self.isExpanded ? .pi : 0.0) : 0.0)
        //debugPrint(self.categoryData?[section].image)
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
                    self.expandSection(tag)
                    view.arrowImageView.rotate(.pi)
                    //return
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
            self.categoryTableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    func collapseSection(_ section:Int) {
        self.selectedSection = -1
        if let headerView = self.categoryTableView.headerView(forSection: section) as? PreferencesSection {
            headerView.arrowImageView.rotate(0.0)
        }
        var indexPaths:[IndexPath] = []
        for i in 0..<(self.categoryData?[section].subCategories?.count ?? 0) {
            let indexPath = IndexPath(row: i, section: section)
            indexPaths.append(indexPath)
        }
        if indexPaths.count > 0 {
            self.categoryTableView.deleteRows(at: indexPaths, with: .fade)
        }
        //self.categoryTableView.reloadData()
        self.isExpanded = false
    }
    
    func makeSectionSelected(section: Int, _ isSelected:Bool = false) {
        if self.categoryData?[section].isCategorySelected != isSelected {
            self.categoryData?[section].isCategorySelected = isSelected
            self.categoryTableView.beginUpdates()
            self.categoryTableView.reloadSections([section], with: .automatic)
            self.categoryTableView.endUpdates()
        }
    }
}

extension CategoryVC:TopBarViewDelegate {
    // MARK: - TopBarDelegate
    func didTapLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CategoryVC {
    // MARK: - Web services
    func getCategoryList() {
        self.view.showLoader()
        DataManager.shared.getCategory { (lists, _, error) in
            self.view.hideLoader()
            if error == nil {
                guard let category = lists else { return }
                self.categoryData = category
                self.setupData()
            } else {
                // Show error
            }
        }
    }
}
