//
//  SearchBothInventoryCVCell.swift
//  IntervalApp
//
//  Created by Chetu on 8/22/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class SearchBothInventoryCVCell: UICollectionViewCell {
    @IBOutlet weak var bedRoomType: UILabel!
    @IBOutlet weak var sleeps: UILabel!
    @IBOutlet weak var kitchenType: UILabel!
    
    @IBOutlet weak var promotionsView: UIView!
    
    @IBOutlet weak var imgViewGetaway: UIImageView!
    
    @IBOutlet weak var imgViewExchange: UIImageView!
    
    func setDataForBothInventoryType(invetoryItem: Resort, indexPath: IndexPath) {
        
        if let unit = (invetoryItem.inventory?.units[indexPath.item]) {
            
            // bedroom details
            
            if let bedType = unit.unitSize {
                bedRoomType.text = Helper.getBrEnums(brType: bedType)
            }
            if let kitchen = unit.kitchenType {
                kitchenType.text = Helper.getKitchenEnums(kitchenType: kitchen)
            }
            
            var totalSleepCapacity = String()
            if unit.publicSleepCapacity > 0 {
                totalSleepCapacity = "\(unit.publicSleepCapacity) total, ".localized()
            }
            
            if unit.privateSleepCapacity > 0 {
                sleeps.text = totalSleepCapacity + String(unit.privateSleepCapacity) + Constant.CommonLocalisedString.privateString
            }
            
            if let promotions = invetoryItem.inventory?.units[indexPath.item].promotions {
                
                if promotions.count > 0 {
                    for view in self.promotionsView.subviews {
                        view.removeFromSuperview()
                    }
                    var yPosition: CGFloat = 0
                    for promotion in promotions {
                        let imgV = UIImageView(frame: CGRect(x: 10, y: yPosition, width: 15, height: 15))
                        imgV.image = UIImage(named: Constant.assetImageNames.promoImage)
                        let promLabel = UILabel(frame: CGRect(x: 30, y: yPosition, width: self.promotionsView.bounds.width, height: 15))
                        promLabel.text = promotion.offerName
                        promLabel.adjustsFontSizeToFitWidth = true
                        promLabel.minimumScaleFactor = 0.7
                        promLabel.numberOfLines = 0
                        promLabel.textColor = UIColor(red: 0, green: 119 / 255, blue: 190 / 255, alpha: 1)
                        promLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 18)
                        self.promotionsView.addSubview(imgV)
                        self.promotionsView.addSubview(promLabel)
                        yPosition += 15
                    }
                }
            }
        }
    }
}
