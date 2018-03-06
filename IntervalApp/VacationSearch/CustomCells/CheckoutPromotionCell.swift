//
//  CheckoutPromotionCell.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 6/20/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class CheckoutPromotionCell: UITableViewCell {

    @IBOutlet weak var promotionTypeLabel: UILabel!
    @IBOutlet weak var promotionNameLabel: UILabel!
    @IBOutlet weak var promotionStatusLabel: UILabel!
    @IBOutlet weak var forwardArrowButton: UIButton!
    @IBOutlet weak var promotionSelectionCheckBox: IUIKCheckbox!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(selectedPromotion: Bool) {
        if selectedPromotion {
            forwardArrowButton.isHidden = true
            promotionSelectionCheckBox.checked = true
            promotionSelectionCheckBox.isHidden = false
            promotionStatusLabel.isHidden = false
            promotionNameLabel.numberOfLines = 2
            if Constant.MyClassConstants.isFromExchange || Constant.MyClassConstants.searchBothExchange {
                promotionNameLabel.text = Constant.MyClassConstants.exchangeFees[0].shopExchange?.selectedOfferName
            } else {
                promotionNameLabel.text = Constant.MyClassConstants.rentalFees[0].rental?.selectedOfferName
            }
        } else {
            promotionSelectionCheckBox.checked = false
            promotionSelectionCheckBox.isHidden = true
            forwardArrowButton.isHidden = false
            promotionNameLabel.text = "Select a Promotion".localized()
            promotionStatusLabel.isHidden = true
        }

    }
    
    func setupDepositPromotion() {
        forwardArrowButton.isHidden = true
        promotionSelectionCheckBox.checked = true
        promotionSelectionCheckBox.isHidden = false
        promotionStatusLabel.isHidden = false
        promotionNameLabel.text = Constant.MyClassConstants.filterRelinquishments[0].openWeek?.promotion?.offerName
        promotionTypeLabel.text = "Deposit Promotion".localized()
        promotionStatusLabel.text = "Automatically Appplied".localized()
    }

}
