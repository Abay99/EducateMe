//
//  UIImageView+Additions.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
private let kFontResizingProportion = 0.42

// MARK: - UIImageView Extension
extension UIImageView {

    /**
     Sets image, created with initials of the string supplied
     - parameter string : string whose initials has to be created
     - returns : new UIImage created from string value supplied
     */
    func setImageWithString(_ string: String) {
        self.setImageWithString(string, isCircular: true, textAttributes: nil)
    }

    /**
     Sets image, created with initials of the string supplied
     - parameter txtString      : string whose initials has to be created
     - parameter color          : background color of image
     - parameter isCircular     : round/square image background
     - parameter textAttributes : attributes for string inside image
     - returns : new UIImage created from string value supplied
     */
    func setImageWithString(_ text: String, isCircular: Bool, textAttributes: [NSAttributedStringKey : Any]?) {

        var textAttr: [NSAttributedStringKey : Any]?
        if textAttributes == nil {
            textAttr = [NSAttributedStringKey.font: self.fontForFontName(nil)!, NSAttributedStringKey.foregroundColor: UIColor.white]
        } else {
            textAttr = textAttributes
        }

        let string: NSString = NSString(string: text)
        let displayString: NSMutableString = NSMutableString(string: "")

        let words: NSMutableArray = NSMutableArray(array: string.components(separatedBy: CharacterSet.whitespacesAndNewlines))

        if words.count > 0 {
            if let firstWord: NSString = words.firstObject as? NSString {
                if firstWord.length > 0 {
                    let firstLetterRange: NSRange = firstWord.rangeOfComposedCharacterSequences(for: NSMakeRange(0, 1))
                    displayString.append(String(firstWord.substring(with: firstLetterRange)))
                }

                if words.count >= 2 {
                    if var lastWord: NSString = words.lastObject as? NSString {
                        while lastWord.length == 0 && words.count >= 2 {
                            words.removeLastObject()
                            lastWord = words.lastObject as! NSString
                        }

                        if words.count > 1 {
                            let lastLetterRange: NSRange = lastWord.rangeOfComposedCharacterSequences(for: NSMakeRange(0, 1))
                            displayString.append(String(lastWord.substring(with: lastLetterRange)))
                        }
                    }
                }
            }
        }

        let backgroundColor: UIColor = self.randomColor()

        image = imageSnapshotFrom(Text: displayString.uppercased, BackgroundColor: backgroundColor, Circular: isCircular, TextAttributes: textAttr!)
    }

    // MARK: - Private functions

    fileprivate func fontForFontName(_ fontName: String?) -> UIFont? {
        let fontSize: CGFloat = (bounds.width) * CGFloat(kFontResizingProportion)
        if fontName == nil {
            return UIFont.systemFont(ofSize: fontSize)
        } else {
            let rVal: UIFont = UIFont(name: fontName!, size: fontSize)!
            return rVal
        }
    }

    fileprivate func randomColor() -> UIColor {
        var red: CGFloat = 0.0
        while red < 0.1 || red > 0.84 {
            red = CGFloat(drand48())
        }

        var green: CGFloat = 0.0
        while green < 0.1 || green > 0.84 {
            green = CGFloat(drand48())
        }

        var blue: CGFloat = 0.0
        while blue < 0.1 || blue > 0.84 {
            blue = CGFloat(drand48())
        }

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    fileprivate func imageSnapshotFrom(Text text: String, BackgroundColor color: UIColor, Circular isCircular: Bool, TextAttributes textAttributes: [NSAttributedStringKey : Any]) -> UIImage? {
        let scale: CGFloat = UIScreen.main.scale

        var size: CGSize = self.bounds.size

        if contentMode == UIViewContentMode.scaleToFill || contentMode == UIViewContentMode.scaleAspectFill || contentMode == UIViewContentMode.scaleAspectFit || contentMode == UIViewContentMode.redraw {
            size.width = CGFloat(floorf(Float(size.width) * Float(scale)) / Float(scale))
            size.height = CGFloat(floorf(Float(size.height) * Float(scale)) / Float(scale))
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        let context: CGContext = UIGraphicsGetCurrentContext()!

        if isCircular {
            //
            // Clip context to a circle
            //
            let path: CGPath = CGPath(ellipseIn: self.bounds, transform: nil)
            context.addPath(path)
            context.clip()
        }

        //
        // Fill background of context
        //
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))

        //
        // Draw text in the context
        //
        let str = NSString(string: text)

        let textSize: CGSize = str.size(withAttributes: textAttributes)
        let bounds: CGRect = self.bounds

        str.draw(in: CGRect(x: bounds.size.width / 2 - textSize.width / 2,
                            y: bounds.size.height / 2 - textSize.height / 2,
                            width: textSize.width,
                            height: textSize.height), withAttributes: textAttributes)

        let snapShot: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return snapShot
    }
}
