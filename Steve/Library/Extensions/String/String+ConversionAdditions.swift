//
//  String+Additions.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
import UIKit

// MARK: - String Extension
//extension String {
//
//    /**
//     Convert html string into  normal string
//     */
//    var html2AttributedString: NSAttributedString? {
//        guard
//            let data = data(using: String.Encoding.utf8)
//        else { return nil }
//        do {
//            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8], documentAttributes: nil)
//        } catch let error as NSError {
//            print(error.localizedDescription)
//            return nil
//        }
//    }
//
//    var html2String: String {
//        return html2AttributedString?.string ?? ""
//    }
//}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
