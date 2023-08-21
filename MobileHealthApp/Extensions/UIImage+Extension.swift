//
//  UIImage+Extension.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 8/21/23.
//

import UIKit

extension UIImage {
//    static func resizedImage(named name: String, to size: CGSize) -> UIImage? {
//        let config = UIImage.SymbolConfiguration(pointSize: min(size.width, size.height))
//        return UIImage(systemName: name, withConfiguration: config)
//    }
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? UIImage()
    }
}
