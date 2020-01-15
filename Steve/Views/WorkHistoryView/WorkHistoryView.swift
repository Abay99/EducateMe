//
//  WorkHistoryView.swift
//  Steve
//
//  Created by Sudhir Kumar on 02/07/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class WorkHistoryView: UIView {

    // IBOutlets
    @IBOutlet weak var workTable: UITableView!
    
    // Variables
    var workHistories:[WorkHistories] = []
    
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = Bundle.main.loadNibNamed(ViewIdentifier.workHistoryView.value, owner: self, options: nil)?[0] as! UIView
        view.frame = bounds
        view.backgroundColor = .clear
        self.updateUI()
        addSubview(view)
        layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Custom Method
    private func updateUI() {
        self.workTable.register(WorkDetailCell.nib, forCellReuseIdentifier: "WorkDetailCell")
    }
    
    func setupWorkData(histories:[WorkHistories]) {
//        var newFrame = self.frame
//        newFrame.size.height = 5 * 50
//        self.frame = newFrame
//        self.layoutIfNeeded()
        self.workHistories = histories
        self.workTable.reloadData()
    }
}

extension WorkHistoryView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.workHistories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: WorkDetailCell.identifier, for: indexPath) as? WorkDetailCell {
            cell.configureCell(data:self.workHistories[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}
