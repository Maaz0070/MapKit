//
//  SectionBackgroundFlowLayout.swift
//  RealEstate
//
//  Created by CodeGradients on 02/11/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class SectionBackgroundFlowLayout: UICollectionViewFlowLayout {

    // MARK: prepareLayout
    
    override func prepare() {
        super.prepare()

        register(SCSBCollectionReusableView.self, forDecorationViewOfKind: "sectionBackground")
    }
    
    // MARK: layoutAttributesForElementsInRect
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var allAttributes = [UICollectionViewLayoutAttributes]()
        
        if let attributes = attributes {
            
            for attr in attributes {
                // Look for the first item in a row
                // You can also calculate it by item (remove the second check in the if below and change the tmpWidth and frame origin
                if (attr.representedElementCategory == UICollectionView.ElementCategory.cell && attr.frame.origin.x == self.sectionInset.left) {
                    
                    // Create decoration attributes
                    let decorationAttributes = SCSBCollectionViewLayoutAttributes(forDecorationViewOfKind: "sectionBackground", with: attr.indexPath)
                    // Set the color(s)
//                    if (attr.indexPath.section == 0) {
//                        decorationAttributes.color = #colorLiteral(red: 0.3607843137, green: 0.7019607843, blue: 1, alpha: 1)
//                    } else {
//                        decorationAttributes.color = UIColor.white
//                    }
                    decorationAttributes.color = indexBackground(attr.indexPath)
                    
                    // Make the decoration view span the entire row
                    let tmpWidth = self.collectionView!.contentSize.width
                    decorationAttributes.frame = CGRect(x: 0, y: attr.frame.origin.y - self.sectionInset.top, width: tmpWidth, height: size(attr.indexPath).height + self.sectionInset.bottom)
                    
                    // Set the zIndex to be behind the item
                    decorationAttributes.zIndex = attr.zIndex - 1
                    
                    // Add the attribute to the list
                    allAttributes.append(decorationAttributes)
                }
            }
            // Combine the items and decorations arrays
            allAttributes.append(contentsOf: attributes)
        }
        
        return allAttributes
    }
    
    private func size(_ indexPath: IndexPath) -> CGSize {
        guard let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout,
            let size = delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: indexPath) else {
                assertionFailure("Implement collectionView(_,layout:,sizeForItemAt: in UICollectionViewDelegateFlowLayout")
                return .zero
        }
        
        return size
    }
    
    private func indexBackground(_ indexPath: IndexPath) -> UIColor {
        if let delegate = collectionView?.delegate as? SectionColorDelegate {
            return delegate.collectionView(sectionColorAt: indexPath)
//            if check {
//                return #colorLiteral(red: 0.3607843137, green: 0.7019607843, blue: 1, alpha: 1)
//            }
        }
        return .white
    }
}



class SCSBCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes {
    var color: UIColor = UIColor.white
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let newAttributes: SCSBCollectionViewLayoutAttributes = super.copy(with: zone) as! SCSBCollectionViewLayoutAttributes
        newAttributes.color = self.color.copy(with: zone) as! UIColor
        return newAttributes
    }
}

class SCSBCollectionReusableView : UICollectionReusableView {
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let scLayoutAttributes = layoutAttributes as! SCSBCollectionViewLayoutAttributes
        self.backgroundColor = scLayoutAttributes.color
    }
}
