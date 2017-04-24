//
//  ClubPointsCollectionViewLayout.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 4/6/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class ClubPointsCollectionViewLayout: UICollectionViewLayout {
    
    let numberOfColumns = 6
    var itemAttributes: [[UICollectionViewLayoutAttributes]]?
    var itemsSize : NSMutableArray! = []
    var contentSize : CGSize!
    
    override func prepare() {
        //itemAttributes = []
        if self.collectionView?.numberOfSections == 0 {
            return
        }
        
        if (self.itemAttributes != nil && (self.itemAttributes?.count)! > 0) {
            for section in 0..<self.collectionView!.numberOfSections {
                let numberOfItems : Int = self.collectionView!.numberOfItems(inSection: section)
                for index in 0..<numberOfItems {
                    if section != 0 && index != 0 {
                        continue
                    }
                    
                    //let attributes : UICollectionViewLayoutAttributes = self.layoutAttributesForItem(at: IndexPath(item: index, section: section))!
                    let indexPath = IndexPath(item: index, section: section)
                    let attributes : UICollectionViewLayoutAttributes = self.layoutAttributesForItem(at: indexPath)!
                    
                    if section == 0 {
                        var frame = attributes.frame
                        frame.origin.y = self.collectionView!.contentOffset.y
                        attributes.frame = frame
                    }
                    
                    if index == 0 {
                        var frame = attributes.frame
                        frame.origin.x = self.collectionView!.contentOffset.x
                        attributes.frame = frame
                    }
                }
            }
            return
        }
        
        if (self.itemsSize == nil || self.itemsSize.count != numberOfColumns) {
            self.calculateItemsSize()
        }
        
        var column = 0
        var xOffset : CGFloat = 0
        var yOffset : CGFloat = 0
        var contentWidth : CGFloat = 0
        var contentHeight : CGFloat = 0
        
        for section in 0..<self.collectionView!.numberOfSections {
            let sectionAttributes = NSMutableArray()
            
            for index in 0..<numberOfColumns {
                let itemSize = (self.itemsSize[index] as AnyObject).cgSizeValue
                let indexPath = IndexPath(item: index, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: (itemSize?.width)!, height: 80).integral
                
                if section == 0 && index == 0 {
                    attributes.zIndex = 1024;
                } else  if section == 0 || index == 0 {
                    attributes.zIndex = 1023
                }
                
                if section == 0 {
                    var frame = attributes.frame
                    frame.origin.y = self.collectionView!.contentOffset.y
                    attributes.frame = frame
                }
                if index == 0 {
                    var frame = attributes.frame
                    frame.origin.x = self.collectionView!.contentOffset.x
                    attributes.frame = frame
                }
                
                sectionAttributes.add(attributes)
                
                xOffset += (itemSize?.width)!
                column += 1
                
                if column == numberOfColumns {
                    if xOffset > contentWidth {
                        contentWidth = xOffset
                    }
                    
                    column = 0
                    xOffset = 0
                    yOffset += (itemSize?.height)!
                }
            }
            if (self.itemAttributes == nil) {
                self.itemAttributes = NSMutableArray(capacity: self.collectionView!.numberOfSections) as? [[UICollectionViewLayoutAttributes]]
            }
            self.itemAttributes?.append(sectionAttributes as! [UICollectionViewLayoutAttributes])
        }
        
        let attributes : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: NSIndexPath.init(row: (self.itemAttributes?.count)!, section: (self.itemAttributes?.count)!) as IndexPath)
        contentHeight = attributes.frame.origin.y + attributes.frame.size.height
        self.contentSize = CGSize(width: contentWidth, height: CGFloat(Constant.MyClassConstants.clubIntervalDictionary.count + 1)*80)
    }

    override var collectionViewContentSize : CGSize {
        return self.contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if (indexPath.section >= (itemAttributes?.count)!) {
            return nil;
        } else if (indexPath.item >= (itemAttributes?[indexPath.section].count)!) {
            return nil;
        }
        return itemAttributes?[indexPath.section][indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        if self.itemAttributes != nil {
            if let itemAttributes1 = self.itemAttributes! as NSArray as? [[UICollectionViewLayoutAttributes]] {
                for section in itemAttributes1 {
                    
                    let filteredArray  =  section.filter{evaluatedObject in
                        return rect.intersects(evaluatedObject.frame)
                    }
                    
                    
                    attributes.append(contentsOf: filteredArray)
                }
            }
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func sizeForItemWithColumnIndex(_ columnIndex: Int) -> CGSize {
        var text : String = ""
        switch (columnIndex) {
        case 0:
            text = "Studio"
        case 1:
            text = "1 Bedroom"
        case 2:
            text = "2 Bedroom"
        case 3:
            text = "3 Bedroom"
        case 4:
            text = "4 Bedroom"
        default:
            text = "Col 7"
        }
        
        let size : CGSize = (text as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15.0)])
        let width : CGFloat = size.width + 40
        return CGSize(width: width, height: 80)
    }
    
    func calculateItemsSize() {
        self.itemsSize = NSMutableArray(capacity: numberOfColumns)
        for index in 0..<numberOfColumns {
            self.itemsSize.add(NSValue(cgSize: self.sizeForItemWithColumnIndex(index)))
        }
    }
}
