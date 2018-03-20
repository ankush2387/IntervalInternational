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

    // MARK: - Private properties
    private var callBack: CallBack?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Public functions
    func setupCell(selectedPromotion: Bool, callBack: @escaping CallBack) {
        self.callBack = callBack

        let cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(cellTapGesture)
        
        if selectedPromotion {
            forwardArrowButton.isHidden = true
            promotionSelectionCheckBox.checked = true
            promotionSelectionCheckBox.isHidden = false
            promotionStatusLabel.isHidden = false
            promotionNameLabel.numberOfLines = 2
            promotionNameLabel.text = Constant.MyClassConstants.selectedDestinationPromotionDisplayName
        } else {
            forwardArrowButton.isHidden = false
            promotionSelectionCheckBox.checked = false
            promotionSelectionCheckBox.isHidden = true
            promotionNameLabel.text = "Select a Promotion".localized()
            promotionStatusLabel.isHidden = true
        }
    }

    func setupDepositPromotion() {
        forwardArrowButton.isHidden = true
        promotionSelectionCheckBox.checked = true
        promotionSelectionCheckBox.isHidden = false
        promotionStatusLabel.isHidden = false
        promotionNameLabel.text = Constant.MyClassConstants.filterRelinquishments[0].openWeek?.promotion?.offerContentFragment
        promotionTypeLabel.text = "Deposit Promotion".localized()
        promotionStatusLabel.text = "Automatically Appplied".localized()
    }
    
    // MARK: - Private functions
    @objc private func cellTapped() {
        callBack?()
    }

}
