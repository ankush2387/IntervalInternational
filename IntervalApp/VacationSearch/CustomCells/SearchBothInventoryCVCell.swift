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
    
    //***** Custom cell delegate to access the delegate method *****//
    weak var exchangeCellDelegate: ExchangeInventoryCVCellDelegate?

    @IBOutlet private weak var cellPromotionView: CellPromotionView!
    @IBOutlet weak var bedRoomType: UILabel!
    @IBOutlet weak var sleeps: UILabel!
    @IBOutlet weak var kitchenType: UILabel!
    @IBOutlet weak var promotionsView: UIView!
    @IBOutlet weak var imgViewGetaway: UIImageView!
    @IBOutlet weak var imgViewExchange: UIImageView!

    func setBucket(bucket: AvailabilitySectionItemInventoryBucket) {
        
        bedRoomType.text = Helper.getBrEnums(brType: bucket.unit.unitSize.rawValue)
        kitchenType.text = Helper.getKitchenEnums(kitchenType: bucket.unit.kitchenType.rawValue)
        
        var totalSleepCapacity = ""
        if bucket.unit.publicSleepCapacity > 0 {
            totalSleepCapacity += "\(bucket.unit.publicSleepCapacity)" + Constant.CommonLocalisedString.totalString + ", ".localized()
        }
        if bucket.unit.privateSleepCapacity > 0 {
            totalSleepCapacity += "\(bucket.unit.privateSleepCapacity)" + Constant.CommonLocalisedString.privateString + "".localized()
        }
        sleeps.text = totalSleepCapacity
        
        // Default state
        //exchangeStackView.isHidden = false
        imgViewExchange.image = #imageLiteral(resourceName: "ExchangeIcon")
        //exchangeTitleLabel.isHidden = false
        //exchangeImageView.isUserInteractionEnabled = false
        //pointsStackView.isHidden = true
        
        if let exchangePointsCost = bucket.exchangePointsCost, let exchangeMemberPointsRequired = bucket.exchangeMemberPointsRequired {
            if Constant.MyClassConstants.isCIGAvailable && exchangePointsCost != exchangeMemberPointsRequired {
                imgViewExchange.image = #imageLiteral(resourceName: "InfoIcon")

                //imgViewExchange.isUserInteractionEnabled = true
                //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBlurButton))
                //self.addGestureRecognizer(tapGesture)
            } else {
                if exchangePointsCost > 0 {
                    //exchangeStackView.isHidden = true
                    //pointsStackView.isHidden = false
                    
                    //pointsCountLabel.text = "\(String(describing: exchangePointsCost))".localized()
                    
                    // Clean the label
                    //pointsTitleLabel.text = ""
                    
                    if Constant.MyClassConstants.isCIGAvailable {
                        //pointsTitleLabel.text = Constant.CommonLocalisedString.cigPointsString
                    } else if Constant.MyClassConstants.isClubPointsAvailable {
                        //pointsTitleLabel.text = Constant.CommonLocalisedString.clubPointsString
                    }
                }
            }
        }
        
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
    
    func tapBlurButton() {
        exchangeCellDelegate?.infoIconPressed()
    }
}
