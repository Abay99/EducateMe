//
//  DocumentTypeCell.swift
//  Steve
//
//  Created by Rishi Kumar on 22/10/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import Kingfisher

protocol documentCellDelegate {
    func documentPlusCellButtonTap(info:Document)
    func documentRemoveCellButtonTap(info:Document)
    func viewDocumentTap(info:Document)
    
}

class DocumentTypeCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var delButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var delegate:documentCellDelegate?
    var doc:Document?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func plusButtonTap(_ sender: Any) {
        if doc?.imageUrl == nil {
            delegate?.documentPlusCellButtonTap(info:doc!);
        }
        else {
            delegate?.viewDocumentTap(info:doc!);
        }
    }
    
    @IBAction func delButtonTap(_ sender: Any) {
        delegate?.documentRemoveCellButtonTap(info:doc!)
    }
    
    func setUpData(info:Document) {
        delButton.isHidden = true
        activityIndicator.isHidden = true
        if let image = info.imageUrl {
            if let url =  URL(string:image ) {
                    if url.pathExtension == "pdf" {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    addButton.setImage(#imageLiteral(resourceName: "pdfIcon"), for: .normal)
                }
                else {
                    
                    addButton.setImage(UIImage.init(), for: .normal)
                    activityIndicator.isHidden = false
                    activityIndicator.startAnimating()
                    KingfisherManager.shared.retrieveImage(with:url , options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        if url.pathExtension == "pdf" {
                            self.addButton.setImage(#imageLiteral(resourceName: "pdfIcon"), for: .normal)
                        } else {
                            self.addButton.setImage(image, for: .normal)
                        }
                    })
                }
            }
            //addButton.setImage(#imageLiteral(resourceName: "pdfIcon"), for: .normal)
            delButton.isHidden = false
        }
        else {
            addButton.setImage(#imageLiteral(resourceName: "plusLargeIcon"), for: .normal)
            if info.isUploadingProgress == true {
                addButton.setImage(UIImage.init(), for: .normal)
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            }
            else {
                addButton.setImage(#imageLiteral(resourceName: "plusLargeIcon"), for: .normal)
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
            }
        }
        titleLabel.text = info.documentName
        doc = info;
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
