//
//  UIView+Animation.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

// MARK: - UIView Extension
extension UIView {

    /**
     Do animation

     - parameter nextView:           View to present
     - parameter duration:           Duration of the animation
     - parameter type:               The name of the transition. Current legal transition types include `fade', `moveIn', `push' and `reveal'. Defaults to `fade'.
     - parameter timingFunctionName: The currently supported names are `linear', `easeIn', `easeOut' and `easeInEaseOut' and `default' (the curve used by implicit animations created by Core Animation).
     - parameter subtype:            An optional subtype for the transition. E.g. used to specify the transition direction for motion-based transitions, in which case the legal values are `fromLeft', `fromRight', `fromTop' and `fromBottom'.
     - parameter fillMode:           The legal values are `backwards', `forwards', `both' and `removed'. Defaults to `removed'.
     - parameter animationKey:       Animation key name
     */
    func doAnimation(_ view: UIView, duration: Float, type: String, timingFunctionName: String, subtype: String?, fillMode: String, animationKey: String) {
        let animation: CATransition = CATransition()
        animation.duration = CFTimeInterval(duration)
        animation.type = type
        animation.timingFunction = CAMediaTimingFunction(name: timingFunctionName)
        animation.subtype = subtype
        animation.fillMode = fillMode
        view.layer.add(animation, forKey: animationKey)
    }

    /**
     Do animation

     - parameter view:          View to present
     - parameter animationTime: Duration of the animation
     - parameter curve:         curve (default = UIViewAnimationCurveEaseInOut)
     - parameter transition:    animation transition
     */
    func doAnimation(_ view: UIView!, animationTime: Float!, curve: UIViewAnimationCurve, transition: UIViewAnimationTransition) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(curve)
        UIView.setAnimationDuration(TimeInterval(animationTime))
        UIView.setAnimationTransition(transition, for: view, cache: false)
        UIView.commitAnimations()
    }

    /* func viewMoveInFromLeft(nextView: UIView!, animationTime: Float!, animationKey: String!) {
     doAnimation(nextView, duration: animationTime, type: "moveIn", timingFunctionName: "easeInEaseOut", subtype: "fromLeft", fillMode: "forwards", animationKey: animationKey)
     }

     func viewMoveInFromRight(nextView: UIView!, animationTime: Float!, animationKey: String!) {
     doAnimation(nextView, duration: animationTime, type: "moveIn", timingFunctionName: "easeInEaseOut", subtype: "fromRight", fillMode: "forwards", animationKey: animationKey)
     }

     func viewMoveInFromTop(nextView: UIView!, animationTime: Float!, animationKey: String!) {
     doAnimation(nextView, duration: animationTime, type: "moveIn", timingFunctionName: "easeInEaseOut", subtype: "fromTop", fillMode: "forwards", animationKey: animationKey)
     }

     func viewMoveInFromBottom(nextView: UIView!, animationTime: Float!, animationKey: String!) {
     doAnimation(nextView, duration: animationTime, type: "moveIn", timingFunctionName: "easeInEaseOut", subtype: "fromBottom", fillMode: "forwards", animationKey: animationKey)
     }

     func viewFadeOut(nextView: UIView!, animationTime: Float!, animationKey: String!) {
     doAnimation(nextView, duration: animationTime, type: "fade", timingFunctionName: "easeOut", subtype: nil, fillMode: "forwards", animationKey: animationKey)
     }

     func viewFadeIn(nextView: UIView!, animationTime: Float!, animationKey: String!) {
     doAnimation(nextView, duration: animationTime, type: "fade", timingFunctionName: "easeIn", subtype: nil, fillMode: "forwards", animationKey: animationKey)
     }

     func viewPushUp(view: UIView!, animationTime: Float!, animationKey: String!) {
     doAnimation(view, duration: animationTime, type: "push", timingFunctionName: "easeOut", subtype: "fromTop", fillMode: "forwards", animationKey: animationKey)
     }

     func viewPushDown(view: UIView!, animationTime: Float!, animationKey: String!) {
     doAnimation(view, duration: animationTime, type: "push", timingFunctionName: "easeOut", subtype: "fromBottom", fillMode: "forwards", animationKey: animationKey)
     }

     func viewPushLeft(view: UIView!, animationTime: Float!, animationKey: String!) {
     doAnimation(view, duration: animationTime, type: "push", timingFunctionName: "easeOut", subtype: "fromLeft", fillMode: "forwards", animationKey: animationKey)
     }

     func viewPushRight(view: UIView!, animationTime: Float!, animationKey: String!) {
     doAnimation(view, duration: animationTime, type: "push", timingFunctionName: "easeOut", subtype: "fromRight", fillMode: "forwards", animationKey: animationKey)
     } */

    /* func viewFlipFromLeft(view: UIView!, animationTime: Float!) {
     doAnimation(view, animationTime: animationTime, curve: UIViewAnimationCurve.EaseInOut, transition: UIViewAnimationTransition.FlipFromLeft)
     }

     func viewFlipFromRight(view: UIView!, animationTime: Float!) {
     doAnimation(view, animationTime: animationTime, curve: UIViewAnimationCurve.EaseInOut, transition: UIViewAnimationTransition.FlipFromRight)
     }

     func viewCurup(view: UIView!, animationTime: Float!) {
     doAnimation(view, animationTime: animationTime, curve: UIViewAnimationCurve.EaseInOut, transition: UIViewAnimationTransition.CurlUp)
     }

     func viewCurdown(view: UIView!, animationTime: Float!) {
     doAnimation(view, animationTime: animationTime, curve: UIViewAnimationCurve.EaseInOut, transition: UIViewAnimationTransition.CurlDown)
     } */

    func animationRotateAndScaleEffects(_ view: UIView!, animationTime: Float!) {
        UIView.animate(withDuration: TimeInterval(animationTime), animations: {
            view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform")

            animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Double.pi), 1, 0, 0))
            animation.duration = CFTimeInterval(animationTime)
        }, completion: { _ in
            UIView.animate(withDuration: TimeInterval(animationTime), animations: {
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        })
    }
}
