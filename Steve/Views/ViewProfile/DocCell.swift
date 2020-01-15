//
//  DocCell.swift
//  Steve
//
//  Created by Rishi Kumar on 25/10/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Kingfisher
class DocCell: UICollectionViewCell {
    
    @IBOutlet weak var docButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.docButton.setImage(UIImage.init(), for: .normal)
    }
    
    func setupData(info:Doc) {
        if let image = info.imageUrl {
            if let url =  URL(string:image ) {
                  if url.pathExtension == "pdf" {
                     self.docButton.setImage(#imageLiteral(resourceName: "pdfIcon"), for: .normal)
                }
                else {
                docButton.setImage(UIImage.init(), for: .normal)
                KingfisherManager.shared.retrieveImage(with:url , options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                        self.docButton.setImage(image, for: .normal)
                })
              //  if url.pathExtension == "pdf" {
               //     docButton.setImage(#imageLiteral(resourceName: "pdfIcon"), for: .normal)
               // }
            }
            }
        }
    }
}
