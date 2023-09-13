//
//  CenterAlignedCollectionViewFlowLayout.swift
//  MobileHealthApp
//
//  Created by Fawwaz Firdaus on 9/11/23.
//

import UIKit

class CenterAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect),
            let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
            else { return nil }

        // Constants
        let leftPadding: CGFloat = 8
        let interItemSpacing: CGFloat = 5

        // Tracking variables
        var leftMargin: CGFloat = leftPadding
        var maxY: CGFloat = -1.0

        // Loop through and adjust items
        for attribute in attributes {
            if attribute.frame.origin.y >= maxY {
                leftMargin = leftPadding
            }

            attribute.frame.origin.x = leftMargin

            leftMargin += attribute.frame.width + interItemSpacing
            maxY = max(attribute.frame.maxY, maxY)
        }

        return attributes
    }
}

//import UIKit
//
//class CenterAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
//
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        let attributes = super.layoutAttributesForElements(in: rect)?.map { $0.copy() as! UICollectionViewLayoutAttributes }
//
//        // Constants
//        let collectionViewWidth = collectionView!.frame.width
//
//        // No attributes or collection view width is zero
//        guard let attributesArray = attributes, collectionViewWidth > 0 else {
//            return attributes
//        }
//
//        // Process attributes
//        var leftMargin: CGFloat = 0.0
//        var lastFrame: CGRect = .zero
//
//        for attribute in attributesArray {
//            if attribute.frame.origin.x != lastFrame.origin.x {
//                leftMargin = (collectionViewWidth - attribute.frame.width) / 2.0
//            }
//
//            attribute.frame.origin.x = leftMargin
//            lastFrame = attribute.frame
//        }
//
//        return attributesArray
//    }
//}


