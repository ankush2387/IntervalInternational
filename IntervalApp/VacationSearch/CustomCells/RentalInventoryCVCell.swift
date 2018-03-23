//
//  RentalInventoryCVCell.swift
//  IntervalApp
//
//  Created by Chetu on 09/08/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class RentalInventoryCVCell: UICollectionViewCell {
    
    @IBOutlet private weak var cellPromotionView: CellPromotionView!
    @IBOutlet weak var getawayNameLabel: UILabel!
    @IBOutlet weak var getawayPrice: UILabel!
    @IBOutlet weak var bedRoomType: UILabel!
    @IBOutlet weak var sleeps: UILabel!
    @IBOutlet weak var kitchenType: UILabel!
    @IBOutlet weak var promotionsView: UIView!
    //@IBOutlet weak var currencySymbol: UILabel!
    @IBOutlet weak var imgViewGetaway: UIImageView!

    func setBucket(bucket: AvailabilitySectionItemInventoryBucket) {

        if Constant.MyClassConstants.isFromSearchBoth {
            imgViewGetaway.isHidden = false
            getawayNameLabel.text = "Getaway"
            getawayPrice.isHidden = true
        } else {
            imgViewGetaway.isHidden = true
            getawayNameLabel.text = "Per Week"
  
            if let formatedRentalPrice = getFormatedRentalPrice(bucket: bucket) {
                getawayPrice.attributedText = formatedRentalPrice
                getawayPrice.isHidden = false
            }
        }

        bedRoomType.text = " \(Helper.getBrEnums(brType: bucket.unit.unitSize.rawValue))"
        kitchenType.text = " \( Helper.getKitchenEnums(kitchenType: bucket.unit.kitchenType.rawValue))"
        
        var totalSleepCapacity = ""
        if bucket.unit.publicSleepCapacity > 0 {
            totalSleepCapacity += "\(bucket.unit.publicSleepCapacity)" + Constant.CommonLocalisedString.totalString + ", ".localized()
        }
        if bucket.unit.privateSleepCapacity > 0 {
            totalSleepCapacity += "\(bucket.unit.privateSleepCapacity)" + Constant.CommonLocalisedString.privateString + "".localized()
        }
        sleeps.text = totalSleepCapacity

        // Promotions
        if let promotions = bucket.promotions, promotions.count > 0 {
            for view in promotionsView.subviews {
                view.removeFromSuperview()
            }
            
            var yPosition: CGFloat = 0
            for promotion in promotions {
                let imgV = UIImageView(frame: CGRect(x: 10, y: yPosition, width: 15, height: 15))
                imgV.image = UIImage(named: Constant.assetImageNames.promoImage)
                let promLabel = UILabel(frame: CGRect(x: 30, y: yPosition, width: promotionsView.bounds.width, height: 15))
                promLabel.text = promotion.offerContentFragment
                promLabel.adjustsFontSizeToFitWidth = true
                promLabel.minimumScaleFactor = 0.7
                promLabel.numberOfLines = 0
                promLabel.textColor = UIColor(red: 0, green: 119 / 255, blue: 190 / 255, alpha: 1)
                promLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 18)
                promotionsView.addSubview(imgV)
                promotionsView.addSubview(promLabel)
                yPosition += 15
            }
        }

        cellPromotionView.setPromotionUI(for: bucket.unit)
    }
    
    fileprivate func getFormatedRentalPrice(bucket: AvailabilitySectionItemInventoryBucket) -> NSAttributedString? {
        var currencyCode = "USD"
        if let currencyCodeValue = bucket.currencyCode {
            currencyCode = currencyCodeValue
        }
        
        var countryCode: String?
        if let currentProfile = Session.sharedSession.contact {
            countryCode = currentProfile.getCountryCode()
        }
        
        if let currentMembership = Session.sharedSession.selectedMembership, let bestRentalPriceValue = IntervalHelper.getBestRentalPrice(currentMembership, prices: bucket.rentalPrices) {
            return bestRentalPriceValue.price.currencyFormatter(for: currencyCode, for: countryCode)
        }
        
        return nil
    }
}
