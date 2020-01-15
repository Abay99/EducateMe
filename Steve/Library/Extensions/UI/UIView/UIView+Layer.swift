//
//  UIView+Layer.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/02/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

extension UIView {
   
    public func dropShadow(shadowOffset: CGSize = CGSize(width: 0, height: 5), radius: CGFloat = 14, color: UIColor = UIColor.lightGray, shadowOpacity: Float = 0.8) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    
    public func roundCorner(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    public func addDashedBorder(_ borderColor:UIColor = UIColor.black, lineWidth:CGFloat = 1, dashPattern:[NSNumber] = [3,3]) {
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.lineWidth = lineWidth
        //shapeLayer.lineJoin = kCALineCapButt
        shapeLayer.lineDashPattern = dashPattern
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 0).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
    public func addPlainBorder(_ borderColor:UIColor = UIColor.black, lineWidth:CGFloat = 1) {
        self.layer.borderWidth = lineWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
    public func removeBorder() {
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
    }

    public func roundSpecificCorner(corners:UIRectCorner, cornerRadius:CGFloat = 5.0){
        let path = UIBezierPath(roundedRect:self.bounds,
                                byRoundingCorners:corners,
                                cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.backgroundColor = UIColor.clear.cgColor
        self.layer.mask = maskLayer
    
    }
}

extension UIView {
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        self.layer.add(animation, forKey: nil)
    }
    
    func rotateArrow(_ shouldRotateArrow:Bool = false) {
        let angle: CGFloat = shouldRotateArrow ? .pi / 2 : 0
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut, animations: {
            
            self.transform = CGAffineTransform(rotationAngle: angle)
        })
    }
}
