//
//  MemberAlert.swift
//  Steve
//
//  Created by Sudhir Kumar on 25/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

enum ActionType:Int {
    case facebookSignUp
    case signUp
    case signIn
    case cancel
}

class MemberAlert: UIView {

    // Variables
    var completion:((ActionType)-> Void)?
    
    // MARK: - Intialization
    class func createAlert() -> MemberAlert {
        let alertView = Bundle.main.loadNibNamed("MemberAlert", owner: self, options: nil)?[0] as! MemberAlert
        //alertView.modifyUI()
        return alertView
    }
    
    // MARK: - Custom Method
    private func modifyUI() {
        let  p0 = CGPoint(x: 0 , y: 155)
        let  p1 = CGPoint(x: ScreenSize.SCREEN_WIDTH, y: 155)
        self.drawDottedLine(start: p0, end: p1)
    }
    
    private func drawDottedLine(start p0: CGPoint, end p1: CGPoint) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = CustomColor.labelDarkTextColor.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [2, 2] // 7 is the length of dash, 3 is length of the gap.
        
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
    
    // MARK: - IBActions
    @IBAction func buttonActions(btn:UIButton) {
        var type:ActionType = .cancel
        switch btn.tag {
//        case 1:
//            type = .facebookSignUp
//            break
        case 2:
            type = .signUp
            break
        case 3:
            type = .signIn
            break
        default:
            type = .cancel
            break
        }
        
        if self.completion != nil {
            self.completion!(type)
        }
    }
}
