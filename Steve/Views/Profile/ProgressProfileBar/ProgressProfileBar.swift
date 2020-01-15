//
//  ProgressProfileBar.swift
//  Steve
//
//  Created by Sudhir Kumar on 15/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class ProgressProfileBar: UIView {
    // IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!

    // Variables
    let titleTexts:[String] = ["About", "Personal", "Preferences", "Location"]
    var currentSelectedIndex = 0
    
    //MARK: - Initializers
    required init(coder: NSCoder?) {
        super.init(coder: coder!)!
        let view = Bundle.main.loadNibNamed(ViewIdentifier.profileCollection.value, owner: self, options: nil)?[0] as! UIView
        view.frame = bounds
        self.modifyUI()
        addSubview(view)
        layoutIfNeeded()
    }
    
    func modifyUI() {
        self.collectionView.register(ProfileCollectionCell.self, forCellWithReuseIdentifier: CellIdentifier.profileColCell.value)
    }
    
    func updateView() {
        self.collectionView.reloadData()
    }
}

extension ProgressProfileBar:UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - UICollection DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titleTexts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.profileColCell.value, for: indexPath) as! ProfileCollectionCell
        cell.setHeading(text:self.titleTexts[indexPath.row], isSelected:(self.currentSelectedIndex == indexPath.row), hide: (indexPath.row == 0) ? .left : (indexPath.row == self.titleTexts.count - 1) ? .right : .none)
        return cell
    }
    
    // MARK: - CollectionView Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let newSize = (ScreenSize.SCREEN_WIDTH - 3)/4
        return CGSize(width: newSize, height: self.collectionView.frame.size.height)
    }
}
