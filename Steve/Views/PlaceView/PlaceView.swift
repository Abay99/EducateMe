//
//  PlaceView.swift
//  Steve
//
//  Created by Sudhir Kumar on 26/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import GooglePlaces

class PlaceView: UIView {

    // IBOutlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var placeTableView: UITableView!
    
    // Variables
    var completion:((_ result:GMSAutocompletePrediction)->Void)?
    private var datasource:NSMutableArray = NSMutableArray()
    
    // MARK: - Initialization
    class func placeTable() -> PlaceView {
        let view = Bundle.main.loadNibNamed("PlaceView", owner: self, options: nil)?[0] as! PlaceView
        view.modifyUI()
        return view
    }
    
    // MARK: - Custom Method
    private func modifyUI() {
        self.placeTableView.delegate = self
        self.placeTableView.dataSource = self
        self.shadowView.dropShadow(radius: 8, color: CustomColor.alertShadowColor)
    }
    
    func loadTableData(datasource:NSMutableArray) {
        self.datasource = datasource
        self.placeTableView.reloadData()
    }
}

extension PlaceView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "kCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "kCell")
            cell?.textLabel?.textColor = CustomColor.profileSelectedTextColor
            cell?.textLabel?.font = UIFont(name: Font.MontserratLight, size: 12)
            cell?.textLabel?.text = ""
        }
        let result: GMSAutocompletePrediction = self.datasource.object(at: indexPath.row) as! GMSAutocompletePrediction
        cell?.textLabel?.text = result.attributedFullText.string
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result: GMSAutocompletePrediction = self.datasource.object(at: indexPath.row) as! GMSAutocompletePrediction
        if self.completion != nil {
            self.completion!(result)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
}
