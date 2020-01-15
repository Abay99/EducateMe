//
//  TopMessage.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit





final class TopMessage {
    
    private   var heightVal = UIScreen.main.bounds.maxY * (60/667)
    private   var showFrame = CGRect()
    private   var hideFrame = CGRect()
    private  var messageView = UIView()
    private  var label = UILabel()
    var window:UIWindow?
    var completion: ClosureType?

    
    // Can't init is singleton
    private init() {
        setupTopMessage()
    }
    //MARK: Shared Instance
    static let shared: TopMessage = TopMessage()
    
    private func setupTopMessage(){
        
        window = UIWindow()
        window?.windowLevel = UIWindowLevelAlert + 1
        window?.frame =  CGRect(x: 0  , y: 0, width: UIScreen.main.bounds.maxX, height: UIScreen.main.bounds.maxY/2)
        window?.backgroundColor = UIColor.clear
        
        hideFrame = CGRect(x: 0, y: -heightVal, width: UIScreen.main.bounds.maxX, height: heightVal)
        showFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.maxX, height: heightVal)
        messageView = UIView(frame: hideFrame)
        window?.addSubview(messageView)
        window?.frame = messageView.frame
        
        label =  UILabel(frame: CGRect(x: 10, y: 33, width: UIScreen.main.bounds.maxX - 20, height: 15))
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.white
        label.font = UIFont(name: "Gotham-Book", size: 14)
        messageView.addSubview(label)
        messageView.backgroundColor = UIColor().colorWithRedValue(69, greenValue: 91, blueValue: 106, alpha: 1)
    }
    
    
    func showMessageWithText(text:String,completion: ClosureType?) {
        label.text = text
        self.completion = completion
        self.window?.isHidden = false
        let height = Utilities.heightForView(text: label.text!, font: label.font, width:label.frame.size.width)
        if height > 15 {
            label.frame = CGRect(x: label.frame.origin.x, y: label.frame.origin.y, width: label.frame.size.width, height: height)
        }else{
            label.frame = CGRect(x: label.frame.origin.x, y: label.frame.origin.y, width: label.frame.size.width, height: 15)
        }
        let diff = height - 15
        if diff > 0 {
            let newHeightVal = heightVal + diff
            hideFrame = CGRect(x: 0, y: -newHeightVal, width: UIScreen.main.bounds.maxX, height: newHeightVal)
            showFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.maxX, height: newHeightVal)
            self.messageView.frame = hideFrame
        }else{
            hideFrame = CGRect(x: 0, y: -heightVal, width: UIScreen.main.bounds.maxX, height: heightVal)
            showFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.maxX, height: heightVal)
            self.messageView.frame = hideFrame
        }
        window?.frame = messageView.frame
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .allowAnimatedContent, animations: {
            
            let height = self.label.frame.height - 15
            if height > 0 {
                self.messageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.maxX, height: height + self.heightVal )
            }else{
                self.messageView.frame = self.showFrame
            }
           self.window?.frame = self.messageView.frame
            
        }, completion:nil)
        self.hideMessage()
    }
    
    
    private  func hideMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .allowAnimatedContent, animations: {
                self.messageView.frame = self.hideFrame
                self.window?.frame = self.messageView.frame
            }, completion: { (_: Bool) in
                if let completion = self.completion {
                    completion()
                }
            })
            
//            UIView.animate(withDuration: 0.5, delay: 0.0, options: .allowAnimatedContent, animations: {
//                self.messageView.frame = self.hideFrame
//                self.window?.frame = self.messageView.frame
//            }, completion: nil)
        }
    }
    
    
    
}
