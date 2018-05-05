//
//  ActiveGameLayout.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/3/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//

import UIKit

class GameLayout: UICollectionViewLayout {
    
    private enum Element: String {
        case sectionHeader
        case cell
    }
    
    private var cache = [Element: [IndexPath: UICollectionViewLayoutAttributes]]()
    private var oldBounds = CGRect.zero

    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat = 0
    
    private var headerHeight: CGFloat = 60
    private var itemHeight: CGFloat = 30
    private var sectionWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let fullWidth = collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        
        if collectionView.numberOfSections <= 5 {
            return fullWidth / CGFloat(collectionView.numberOfSections)
        } else {
            return fullWidth / 6
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
        contentWidth = 0
        contentHeight = 0
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if oldBounds.size != newBounds.size {
            cache.removeAll(keepingCapacity: true)
        }
        return true
    }
    
    override func prepare() {
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        
        cache.removeAll()
        cache[.sectionHeader] = [IndexPath: UICollectionViewLayoutAttributes]()
        cache[.cell] = [IndexPath: UICollectionViewLayoutAttributes]()
        oldBounds = collectionView.bounds
        
        var xOffset = [CGFloat]()
        for section in 0 ..< collectionView.numberOfSections {
            xOffset.append(CGFloat(section) * sectionWidth)
        }
        var yOffset = [CGFloat](repeating: headerHeight, count: collectionView.numberOfSections)
        
        for section in 0 ..< collectionView.numberOfSections {
            
            let sectionHeaderAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: section))
            sectionHeaderAttributes.frame = CGRect(x: xOffset[section], y: 0, width: sectionWidth, height: headerHeight)
            sectionHeaderAttributes.zIndex = 1
            cache[.sectionHeader]?[IndexPath(item: 0, section: section)] = sectionHeaderAttributes
            
            for item in 0 ..< collectionView.numberOfItems(inSection: section) {
                
                let indexPath = IndexPath(item: item, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset[section], y: yOffset[section], width: sectionWidth, height: itemHeight)

                cache[.cell]?[indexPath] = attributes
                
                contentHeight = max(contentHeight, attributes.frame.maxY)
                contentWidth = max(contentWidth, attributes.frame.maxX)
                yOffset[section] = yOffset[section] + itemHeight
            }
        }
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[.sectionHeader]?[indexPath]
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[.cell]?[indexPath]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else {
            return nil
        }

        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        for (elementType, elementInfos) in cache {
            for (indexPath, attributes) in elementInfos {
                updateSupplementaryViews(elementType, attributes: attributes, collectionView: collectionView, indexPath: indexPath)
                if attributes.frame.intersects(rect) {
                    visibleLayoutAttributes.append(attributes)
                }
            }
        }
        return visibleLayoutAttributes
    }
    
    private func updateSupplementaryViews(_ type: Element, attributes: UICollectionViewLayoutAttributes, collectionView: UICollectionView, indexPath: IndexPath) {
        if type == .sectionHeader {
            attributes.transform = CGAffineTransform(translationX: 0, y: collectionView.contentOffset.y)
        }
    }
}
