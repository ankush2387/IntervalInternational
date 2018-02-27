//
//  ExchangeInventoryCVCell.swift
//  IntervalApp
//
//  Created by Chetu on 16/08/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

protocol ExchangeInventoryCVCellDelegate: class {
    func infoIconPressed()
}

class ExchangeInventoryCVCell: UICollectionViewCell {
    
    //***** Custom cell delegate to access the delegate method *****//
    weak var exchangeCellDelegate: ExchangeInventoryCVCellDelegate?
    
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
    
    func setUpExchangeCell(invetoryItem: ExchangeInventory, indexPath: IndexPath) {
        
        guard let unit = (invetoryItem.buckets[indexPath.item].unit) else { return }
        
        // bedroom details
        var bedRoomDetails = ""
        if let bedType = unit.unitSize {
            bedRoomDetails.append(" \(String(describing: Helper.getBrEnums(brType: bedType)))")
        }
        
        self.bedRoomType.text = bedRoomDetails
        
        var kitchenDetails = ""
        if let kitchenType = unit.kitchenType {
            kitchenDetails.append(" \(String(describing: Helper.getKitchenEnums(kitchenType: kitchenType)))")
        }
        
        self.kitchenType.text = kitchenDetails
        
        var totalSleepCapacity = String()
        
        if unit.publicSleepCapacity > 0 {
            
            totalSleepCapacity = String(unit.publicSleepCapacity) + " " + Constant.CommonLocalisedString.totalString + ", "
            
        }
        
        if unit.privateSleepCapacity > 0 {

            self.sleeps.text = totalSleepCapacity + String(unit.privateSleepCapacity) + Constant.CommonLocalisedString.privateString
        }
        
        if Constant.MyClassConstants.isCIGAvailable && invetoryItem.buckets[indexPath.row].pointsCost != invetoryItem.buckets[indexPath.row].memberPointsRequired {
            pointsStackView.isHidden = true
            exchangeStackView.isHidden = false
            exchangeImageView.image = #imageLiteral(resourceName: "InfoIcon")
            exchangeImageView.isUserInteractionEnabled = true
            exchangeTitleLabel.isHidden = true
            forwardNavArrow.isHidden = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBlurButton))
            self.addGestureRecognizer(tapGesture)
        } else {
            if  invetoryItem.buckets[indexPath.row].pointsCost != 0 {
                let availablePoints = invetoryItem.buckets[indexPath.row].pointsCost as NSNumber
                exchangeStackView.isHidden = true
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                
                if let availablePoints = numberFormatter.string(from: availablePoints) {
                    pointsCountLabel.text = "\(availablePoints)".localized()
                } else { pointsCountLabel.text = "\(0)".localized() }
                
                if Constant.MyClassConstants.isCIGAvailable {
                    pointsTitleLabel.text = "CIG Points"
                } else if Constant.MyClassConstants.isClubPointsAvailable {
                    pointsTitleLabel.text = "Club Points"
                }
            } else {
                pointsStackView.isHidden = true
            }
        }
    
        let promotions = invetoryItem.buckets[indexPath.item].promotions
        if (promotions.count) > 0 {
            for view in self.promotionsView.subviews {
                view.removeFromSuperview()
            }
            
            var yPosition: CGFloat = 5
            for promotion in promotions {
                let imgV = UIImageView(frame: CGRect(x: 10, y: yPosition, width: 15, height: 15))
                imgV.image = UIImage(named: Constant.assetImageNames.promoImage)
                let promLabel = UILabel(frame: CGRect(x: 30, y: yPosition, width: self.promotionsView.bounds.width, height: 15))
                let attrStr = try? NSAttributedString(
                    data: "\(promotion.offerContentFragment!)".data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                    options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                    documentAttributes: nil)
                promLabel.attributedText = attrStr
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
    }
    
    func tapBlurButton() {
        exchangeCellDelegate?.infoIconPressed()
    }
}
