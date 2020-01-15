//
//  UIImage+Additions.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

extension UIImage {

    public func compressImage(_ maxCompressionQuality: CGFloat = 0.9, maxFileSize: Int = 250 * 1024) -> UIImage? {

        var compressionQuality: CGFloat = 0.9
        var imageData: Data? = UIImageJPEGRepresentation(self, compressionQuality)

        guard let _ = imageData else {
            return nil
        }

        while (imageData?.count)! > maxFileSize && compressionQuality > maxCompressionQuality {
            compressionQuality -= 0.1
            imageData = UIImageJPEGRepresentation(self, compressionQuality)
        }

        let compressedImage = UIImage(data: imageData!)
        return compressedImage
    }

    class func compress(image: UIImage, maxFileSize: Int = 1024 * 1024, compression: CGFloat = 1.0, maxCompression: CGFloat = 0.4) -> Data? {

        if let data = UIImageJPEGRepresentation(image, compression) {

            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
            bcf.countStyle = .file
            let string = bcf.string(fromByteCount: Int64(data.count))
            debugPrint("Data size is: \(string)")

            if data.count > (maxFileSize * 1024 * 1024) && (compression > maxCompression) {
                let newCompression = compression - 0.1
                let compressedData = compress(image: image, maxFileSize: maxFileSize, compression: newCompression, maxCompression: maxCompression)
                return compressedData
            }

            return data
        }

        return nil
    }
}
