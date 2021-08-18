//
//  StickHeaderCollectionViewLayout.swift
//  RealEstate
//
//  Created by CodeGradients on 29/10/2020.
//  Copyright © 2020 Code Gradients. All rights reserved.
//

import UIKit

class StickyHeaderCollectionViewLayout: UICollectionViewFlowLayout {
    
    var stickyRowsCount = 1 {
        didSet {
            invalidateLayout()
        }
    }
    
    var stickyColumnsCount = 5 {
        didSet {
            invalidateLayout()
        }
    }
    
    private var allAttributes: [[UICollectionViewLayoutAttributes]] = []
    private var contentSize = CGSize.zero
    
    func isItemSticky(at indexPath: IndexPath) -> Bool {
        return indexPath.item < stickyColumnsCount || indexPath.section < stickyRowsCount
    }
    
    // MARK: - Collection view flow layout methods
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func prepare() {
        setupAttributes()
        updateStickyItemsPositions()
        
        let lastItemFrame = allAttributes.last?.last?.frame ?? .zero
        contentSize = CGSize(width: lastItemFrame.maxX, height: lastItemFrame.maxY)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for rowAttrs in allAttributes {
            for itemAttrs in rowAttrs where rect.intersects(itemAttrs.frame) {
                layoutAttributes.append(itemAttrs)
            }
        }
        
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // MARK: - Helpers
    
    private func setupAttributes() {
        allAttributes = []
        
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        for row in 0..<rowsCount {
            var rowAttrs: [UICollectionViewLayoutAttributes] = []
            xOffset = 0
            
            for col in 0..<columnsCount(in: row) {
                let itemSize = size(forRow: row, column: col)
                let indexPath = IndexPath(item: col, section: row)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

                if indexPath.item == 0 {
                    attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral
                } else if indexPath.item == 1 {
                    xOffset = 0
                    yOffset += 40
                    attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral
                    xOffset += (itemSize.width + interItemSpacing)
                } else {
                    attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral
                    xOffset += (itemSize.width + interItemSpacing)
                }
//                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral
//
                attributes.zIndex = -1
                
                rowAttrs.append(attributes)
                
//                xOffset += (itemSize.width)
            }
            
            yOffset += ((rowAttrs.last?.frame.height ?? 0.0) + self.sectionInset.bottom)
            allAttributes.append(rowAttrs)
        }
    }
    
    private func updateStickyItemsPositions() {
//        for row in 0..<rowsCount {
            let row = 0
            for col in 0..<columnsCount(in: row) {
                let attributes = allAttributes[row][col]
                
                if row < stickyRowsCount {
                    var frame = attributes.frame
                    frame.origin.x += collectionView!.contentOffset.x
                    attributes.frame = frame
                }
                
                if col < stickyColumnsCount {
                    var frame = attributes.frame
                    frame.origin.y += collectionView!.contentOffset.y
                    attributes.frame = frame
                }
                
                attributes.zIndex = zIndex(forRow: row, column: col)
            }
//        }
    }
    
    private func zIndex(forRow row: Int, column col: Int) -> Int {
        if row < stickyRowsCount && col < stickyColumnsCount {
            return 2
        } else if row < stickyRowsCount || col < stickyColumnsCount {
            return 1
        } else {
            return 0
        }
    }
    
    // MARK: - Sizing
    
    private var rowsCount: Int {
        return collectionView!.numberOfSections
    }
    
    private func columnsCount(in row: Int) -> Int {
        return collectionView!.numberOfItems(inSection: row)
    }
    
    private func size(forRow row: Int, column: Int) -> CGSize {
        guard let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout,
            let size = delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: IndexPath(item: column, section: row)) else {
                assertionFailure("Implement collectionView(_,layout:,sizeForItemAt: in UICollectionViewDelegateFlowLayout")
                return .zero
        }
        
        return size
    }
    
    private var interItemSpacing: CGFloat {
        if let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout {
            let space = delegate.collectionView?(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: 0) ?? 0
            return space
        }
        
        return 0
    }
}
