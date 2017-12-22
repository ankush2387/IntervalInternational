//
//  ExchangeOptionsCell.swift
//  IntervalApp
//
//  Created by Chetu on 15/11/16.
//  Copyright © 2016 Interval Internationa l. All rights reserved.
//

import UIKit
import IntervalUIKit

class ExchangeOptionsCell: UITableViewCell {
    
    //Outlets
    
    @IBOutlet weak var primaryPriceLabel: UILabel!
    @IBOutlet weak var priceCheckBox: IUIKCheckbox!

    func setTotalPrice(with currencyDisplayes: String, and chargeAmount: Float) {

        if let attributedAmount = chargeAmount.currencyFormatter(for:currencyDisplayes) {
            primaryPriceLabel.attributedText = attributedAmount
        }
    }

    func setupCell(selectedEplus: Bool) {
        
        if let currencyCode = Constant.MyClassConstants.exchangeFees[0].currencyCode {
            if Constant.MyClassConstants.exchangeFees.isEmpty && Constant.MyClassConstants.exchangeFees[0].eplus != nil {
                if let eplus = Constant.MyClassConstants.exchangeFees[0].eplus?.price, let selectedTrue = Constant.MyClassConstants.exchangeFees[0].eplus?.selected {
                    priceCheckBox.checked = selectedTrue
                    setTotalPrice(with: currencyCode, and: eplus)
                }
            }
        }
    }
}
