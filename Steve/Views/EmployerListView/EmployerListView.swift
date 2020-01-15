//
//  EmployerListView.swift
//  Steve
//
//  Created by Sudhir Kumar on 02/07/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class EmployerListView: UIView {

    // IBOutlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var employerTableView: UITableView!
    
    // Variables
    var completion:((_ data:Employers)->Void)?
    private var datasource:[Employers]?
    
    // MARK: - Initialization
    class func employerTable() -> EmployerListView {
        let view = (Bundle.main.loadNibNamed("EmployerListView", owner: self, options: nil)?[0] as? EmployerListView) ?? EmployerListView.init(frame: CGRect.zero)
        view.modifyUI()
        return view
    }
    
    // MARK: - Custom Method
    private func modifyUI() {
        self.employerTableView.register(EmployerCell.nib, forCellReuseIdentifier: "EmployerCell")
        self.employerTableView.delegate = self
        self.employerTableView.dataSource = self
        self.shadowView.dropShadow(radius: 8, color: CustomColor.alertShadowColor)
    }
    
    func loadTableData(datasource:[Employers]?) {
        self.datasource = datasource
        self.employerTableView.reloadData()
    }
}

extension EmployerListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datasource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: EmployerCell.identifier, for:indexPath) as? EmployerCell {
            cell.configureEmployerCell(emp: self.datasource![indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.completion != nil {
            self.completion!(self.datasource![indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
}
