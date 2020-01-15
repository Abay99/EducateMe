//
//  TopBarView.swift
//  Steve
//
//  Created by Sudhir Kumar on 28/02/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

@objc protocol TopBarViewDelegate {
    @objc optional func didTapLeftButton()
    @objc optional func didTapRightButton(_ btn: UIButton?)
}

class TopBarView: UIView {
    // IBOutlets
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var navLeftButton: UIButton!
    @IBOutlet weak var navRightButton: UIButton!
    
    // Variables
    weak var delegate:TopBarViewDelegate?
    
    //MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = Bundle.main.loadNibNamed(ViewIdentifier.topView.value, owner: self, options: nil)?[0] as! UIView
        view.frame = bounds
        self.updateUI()
        addSubview(view)
        layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    //MARK: - Custom Method
    private func updateUI() {
        
    }
    
    func setHeaderData(title:String = "", leftButtonImage:String = "", rightButtonImage:String = "") {
        if leftButtonImage != "" {
            self.navLeftButton.isHidden = false
            self.navLeftButton.setImage(UIImage(named:leftButtonImage), for: .normal)
        }
        else{
            self.navLeftButton.isHidden = true
        }
        if rightButtonImage != "" {
            self.navRightButton.isHidden = false
            self.navRightButton.setImage(UIImage(named:rightButtonImage), for: .normal)
        }
        else{
            self.navRightButton.isHidden = true
        }
        self.navTitleLabel.text = title
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.07
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2
    }
    
    //MARK: - IBActions
    
    @IBAction func navLeftButtonClicked() {
        self.delegate?.didTapLeftButton!()
    }
    
    @IBAction func navRightButtonCicked(btn:UIButton) {
        self.delegate?.didTapRightButton!(btn)
    }
    
}
