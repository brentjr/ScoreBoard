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

    private var headerHeight: CGFloat = 30
    private var itemHeight: CGFloat = 60

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
            if section == 0  {
                xOffset.append(0)
            } else {
                xOffset.append(xOffset[section - 1] + CGFloat(widthFor(section: section - 1)))
            }
        }
        var yOffset = [CGFloat](repeating: headerHeight, count: collectionView.numberOfSections)
        
        for section in 0 ..< collectionView.numberOfSections {

            let sectionHeaderAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: section))

            if section == 0 {
                sectionHeaderAttributes.frame = CGRect(x: xOffset[section], y: 0, width: CGFloat(widthFor(section: section)), height: headerHeight)
                sectionHeaderAttributes.zIndex = 3
            } else {
                sectionHeaderAttributes.frame = CGRect(x: xOffset[section], y: 0, width: CGFloat(widthFor(section: section)), height: headerHeight)
                sectionHeaderAttributes.zIndex = 2
            }
            cache[.sectionHeader]?[IndexPath(item: 0, section: section)] = sectionHeaderAttributes

            for item in 0 ..< collectionView.numberOfItems(inSection: section) {
                
                let indexPath = IndexPath(item: item, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset[section], y: yOffset[section], width: CGFloat(widthFor(section: section)), height: itemHeight)
                if indexPath.section == 0 {
                    attributes.zIndex = 1
                }

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
        if indexPath.section == 0 && type == .sectionHeader {
            attributes.transform = CGAffineTransform(translationX: collectionView.contentOffset.x, y: collectionView.contentOffset.y)
        } else if indexPath.section == 0 {
            attributes.transform = CGAffineTransform(translationX: collectionView.contentOffset.x, y: 0)
        } else if type == .sectionHeader {
            attributes.transform = CGAffineTransform(translationX: 0, y: collectionView.contentOffset.y)
        }
    }

    private func widthFor(section: Int) -> Int {
        if section == 0 {
            return 120
        } else {
            return 40
        }
    }

}
