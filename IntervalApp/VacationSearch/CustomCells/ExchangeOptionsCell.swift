//
//  ExchangeOptionsCell.swift
//  IntervalApp
//
//  Created by Chetu on 15/11/16.
//  Copyright © 2016 Interval Internationa l. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class ExchangeOptionsCell: UITableViewCell {
    
    //Outlets
    
    @IBOutlet weak var primaryPriceLabel: UILabel!
    @IBOutlet weak var priceCheckBox: IUIKCheckbox!

    func setTotalPrice(with currencyCode: String, and chargeAmount: Float, and countryCode: String?) {
        if let attributedAmount = chargeAmount.currencyFormatter(for:currencyCode, for: countryCode) {
            primaryPriceLabel.attributedText = attributedAmount
        }
    }

    func setupCell(selectedEplus: Bool) {
        
        //FIXME(Frank) - why we need Constant.MyClassConstants.exchangeFees as a global?
        // Why Constant.MyClassConstants.exchangeFees is an array?
        // if let currencyCode = Constant.MyClassConstants.exchangeFees?.currencyCode {
        
        let currencyCode = Constant.MyClassConstants.exchangeFees?.currencyCode ?? Constant.MyClassConstants.rentalFees?.currencyCode ?? "USD"
        
        var countryCode: String?
        if let currentProfile = Session.sharedSession.contact {
            countryCode = currentProfile.getCountryCode()
        }
        
        //FIXME(Frank) - why the exchangeFees is an array? - this is BAD
        if let exchangeFees = Constant.MyClassConstants.exchangeFees, let eplusFee = exchangeFees.eplus, let selectedEplus = eplusFee.selected {
            priceCheckBox.checked = selectedEplus
            setTotalPrice(with: currencyCode, and: eplusFee.price, and: countryCode)
        }
    }
}
