//
//  ExchangeInventoryCVCell.swift
//  IntervalApp
//
//  Created by Chetu on 16/08/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class ExchangeInventoryCVCell: UICollectionViewCell {
    
    @IBOutlet private weak var cellPromotionView: CellPromotionView!
    @IBOutlet private weak var bedRoomType: UILabel!
    @IBOutlet private weak var sleeps: UILabel!
    @IBOutlet private weak var kitchenType: UILabel!
    @IBOutlet private weak var promotionsView: UIView!
    @IBOutlet private weak var exchangeStackView: UIStackView!
    @IBOutlet private weak var pointsStackView: UIStackView!
    @IBOutlet private weak var pointsCountLabel: UILabel!
    @IBOutlet private weak var pointsTitleLabel: UILabel!
    @IBOutlet private weak var exchangeImageView: UIImageView!
    @IBOutlet private weak var forwardNavArrow: UIImageView!
    @IBOutlet private weak var exchangeTitleLabel: UILabel!
    
    var showNotEnoughPoint: (() -> Void)?
    var notEnoughPoint = Bool () {
        didSet {
            showNotEnoughPoint?()
        }
    }
    func setBucket(bucket: AvailabilitySectionItemInventoryBucket) {
        
        // Setup UI controls
        pointsTitleLabel.textColor = UIColor.lightGray
        pointsTitleLabel.font = UIFont.systemFont(ofSize: 10.0)
        //color = Light Gray Color
        //Font = system - system, style = regular
        //size = 10.0
        
        self.bedRoomType.text = " \(String(describing: Helper.getBrEnums(brType: bucket.unit.unitSize.rawValue)))"
        self.kitchenType.text = " \(String(describing: Helper.getKitchenEnums(kitchenType: bucket.unit.kitchenType.rawValue)))"
        
        var totalSleepCapacity = ""
        if bucket.unit.publicSleepCapacity > 0 {
            totalSleepCapacity += "\(bucket.unit.publicSleepCapacity)" + Constant.CommonLocalisedString.totalString + ", ".localized()
        }
        if bucket.unit.privateSleepCapacity > 0 {
            totalSleepCapacity += "\(bucket.unit.privateSleepCapacity)" + Constant.CommonLocalisedString.privateString + "".localized()
        }
        sleeps.text = totalSleepCapacity
        
        // Default state
        exchangeStackView.isHidden = false
        exchangeImageView.image = #imageLiteral(resourceName: "ExchangeIcon")
        exchangeTitleLabel.isHidden = false
        exchangeImageView.isUserInteractionEnabled = false
        pointsStackView.isHidden = true
        forwardNavArrow.isHidden = false
        
        if let exchangePointsCost = bucket.exchangePointsCost, let exchangeMemberPointsRequired = bucket.exchangeMemberPointsRequired {
            
            switch Constant.exchangePointType {
            case ExchangePointType.CIGPOINTS:
                if exchangePointsCost > exchangeMemberPointsRequired {
                    exchangeImageView.image = #imageLiteral(resourceName: "InfoIcon")
                    exchangeImageView.isUserInteractionEnabled = true
                    forwardNavArrow.isHidden = true
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showNotEnoughPointModel))
                    addGestureRecognizer(tapGesture)
                } else {
                   pointsTitleLabel.text = ExchangePointType.CIGPOINTS.name.localized()
                   exchangeStackView.isHidden = true
                   pointsStackView.isHidden = false
                   pointsCountLabel.text = "\(exchangePointsCost)".localized()
                   gestureRecognizers?.removeAll()
                }
                
            case ExchangePointType.CLUBPOINTS:
               pointsTitleLabel.text = ExchangePointType.CLUBPOINTS.name.localized()
               exchangeStackView.isHidden = true
               pointsStackView.isHidden = false
               pointsCountLabel.text = "\(exchangePointsCost)".localized()

            case .UNKNOWN:
                break
            }
        }

        // Promotions
        if let promotions = bucket.promotions, promotions.count > 0 {
            for view in self.promotionsView.subviews {
                view.removeFromSuperview()
            }
            
            var yPosition: CGFloat = 5
            for promotion in promotions {
                let imgV = UIImageView(frame: CGRect(x: 10, y: yPosition, width: 15, height: 15))
                imgV.image = UIImage(named: Constant.assetImageNames.promoImage)
                let promLabel = UILabel(frame: CGRect(x: 30, y: yPosition, width: self.promotionsView.bounds.width, height: 15))
                promLabel.text = promotion.offerContentFragment
                promLabel.adjustsFontSizeToFitWidth = true
                promLabel.minimumScaleFactor = 0.7
                promLabel.numberOfLines = 0
                promLabel.textColor = #colorLiteral(red: 0, green: 0.4666666667, blue: 0.7450980392, alpha: 1)
                promLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 12)
                self.promotionsView.addSubview(imgV)
                self.promotionsView.addSubview(promLabel)
                yPosition += 15
            }
        }
        cellPromotionView.setPromotionUI(for: bucket.unit)
    }
    func showNotEnoughPointModel() {
        notEnoughPoint = true
    }
}
