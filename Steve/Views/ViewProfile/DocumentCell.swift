//
//  DocumentCell.swift
//  Steve
//
//  Created by Rishi Kumar on 25/10/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class DocumentCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate {

    @IBOutlet weak var pointImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    var docs:[Doc]?
    override func awakeFromNib() {
        super.awakeFromNib()
        let nib = UINib(nibName: "DocCell", bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: "DocCell")
        collectionView?.dataSource = self
        collectionView?.delegate = self
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupData(index:Int)  {
        collectionView.reloadData()
        self.pointImageView.image = UIImage(named: (index % 2 == 1) ?AppImage.blueRadio : AppImage.greyRadio)
    }
    
}

extension DocumentCell {
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return (docs?.count) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DocCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocCell", for: indexPath) as! DocCell
        cell.setupData(info: docs![indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageViewVC = UIStoryboard.navigateToDocImageVC()
        imageViewVC.imageUrl = docs![indexPath.row].imageUrl
        imageViewVC.docName = docs![indexPath.row].documentName
        UIApplication.topViewController()?.present(imageViewVC, animated: true, completion: nil)
    }
}
