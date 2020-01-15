//
//  DropDown.swift
//  Steve
//
//  Created by Sudhir Kumar on 24/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class DropDown: UIView {
    // IBOutlets
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var dropDownTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropDownHeightConstraint: NSLayoutConstraint!

    // Variables
    fileprivate var menuData:[String] = []
    fileprivate var onSelection:((_ index:Int)->Void)?
    
    // MARK: - Initialization
    class func showDropDownWithData(data:[String], anchorView:UIView, completion:((_ index:Int)->Void)?) {
        let view = Bundle.main.loadNibNamed("DropDown", owner: self, options: nil)?[0] as! DropDown
        view.menuData = data
        view.onSelection = completion
        view.updateViewLayout(anchorView)
        view.loadAndShow()
    }
    
    // MARK: - Custom Method
    func updateViewLayout(_ anchorView:UIView) {
        self.dropDownTopConstraint.constant = anchorView.frame.origin.y + anchorView.frame.size.height + 10
        self.dropDownHeightConstraint.constant = CGFloat((self.menuData.count >= 3) ? ((29 * 3) + 31 + 27) : ((29 * self.menuData.count) + 31 + 27))
        self.layoutIfNeeded()
    }
    
    func loadAndShow() {
        self.menuTableView.register(DropDownCell.nib, forCellReuseIdentifier: "DropDownCell")
        self.menuTableView.dataSource = self
        self.menuTableView.delegate = self
        self.menuTableView.reloadData()
        self.showDropDown()
    }
    
    private func showDropDown() {
        let window = kAppDelegate.window
        frame = (window?.bounds)!
        window?.addSubview(self)
        window?.bringSubview(toFront: self)
    }
    
    private func hideDropDown() {
        self.removeFromSuperview()
    }
    
    // MARK: - Toches
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let touchpoint: CGPoint = touch.location(in: self) // [touch locationInView:self.view];
            
            if !self.menuTableView.frame.contains(touchpoint) {
                self.hideDropDown()
            }
        }
    }
}

extension DropDown: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: DropDownCell.identifier, for: indexPath) as? DropDownCell {
            cell.configureData(text: self.menuData[indexPath.row])
            return cell
        }

        return UITableViewCell()
    }
    
    // MARK: - Table Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.onSelection != nil {
            self.onSelection!(indexPath.row)
        }
        self.hideDropDown()
    }
}
