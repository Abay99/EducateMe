//
//  CustomTextView.swift
//  Steve
//
//  Created by Sudhir Kumar on 16/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@IBDesignable
open class CustomTextView: UIView {
    // IBOutlets
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var placeHolderLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewTopConstraint: NSLayoutConstraint!
    
    // Variables
    lazy var isShiftUP:Bool = false
    
    @IBInspectable
    public var placeholderString: String = "" {
        didSet {
            self.placeHolderLabel.text = self.placeholderString
        }
    }
    
    @IBInspectable
    public var placeholderColor: UIColor = .gray {
        didSet {
            self.placeHolderLabel.textColor = self.placeholderColor
        }
    }
    
    @IBInspectable
    public var customText: String = "" {
        didSet {
            self.textView.text = self.customText
            //self.textView.sizeToFit()
            //self.textView.contentSize.height = 36
            self.updateTextViewUI(self.textView)
        }
    }
    
    @IBInspectable
    public var shiftUP: Bool = false {
        didSet {
            self.isShiftUP = self.shiftUP
        }
    }
    
    @IBInspectable
    public var customBackgroundColor: UIColor? {
        didSet {
            self.backgroundColor = self.customBackgroundColor
        }
    }
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = Bundle.main.loadNibNamed(ViewIdentifier.customTextView.value, owner: self, options: nil)?[0] as! UIView
        view.frame = bounds
        self.setContainerInset()
        addSubview(view)
        layoutIfNeeded()
    }
    
    private func setContainerInset() {
        self.placeHolderLabelTopConstraint.constant = 22
        self.textViewTopConstraint.constant = 21
        self.textView.textContainerInset = UIEdgeInsets(top: -2.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.layoutIfNeeded()
    }
}

extension CustomTextView: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        return true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == self.textView {
            let newText = ((textView.text ?? "") as NSString).replacingCharacters(in: range, with: text)
            //let newText = textView.text + text
            if newText.count > 0 {
                self.placeHolderLabelTopConstraint.constant = 3
                self.textViewTopConstraint.constant = 19
            } else {
                self.placeHolderLabelTopConstraint.constant = 22
                self.textViewTopConstraint.constant = 21
            }
            if textView.text.count > 499 && text != "" {
                    return false
            }
        }
        return true
    }
    
    public func updateTextViewUI(_ textView: UITextView) {
        if textView.text.count > 0 {
            self.placeHolderLabelTopConstraint.constant = 3
            self.textViewTopConstraint.constant = 19
        } else {
            self.placeHolderLabelTopConstraint.constant = 22
            self.textViewTopConstraint.constant = 21
        }
        
//        let numLines = Int(textView.contentSize.height / (textView.font?.lineHeight ?? 1.0))
//        let fontHeight = (textView.font?.lineHeight ?? 12) + 7
//        if numLines > 1 {
//            self.textViewTopConstraint.constant = 19
//            self.textViewHeightConstraint.constant = CGFloat((numLines > 3) ? (fontHeight * 3): (fontHeight * CGFloat(numLines)))
//        } else {
//            self.textViewTopConstraint.constant = 6
//            self.textViewHeightConstraint.constant = 36
//        }
    }
}
