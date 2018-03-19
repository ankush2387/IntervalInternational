//
//  TotalCostCell.swift
//  IntervalApp
//
//  Created by Chetu on 16/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class TotalCostCell: UITableViewCell {
    
    @IBOutlet weak private var amountLabel: UILabel!

    func setTotalPrice(with currencyCode: String, and chargeAmount: Float, and countryCode: String?) {
        if let attributedAmount = chargeAmount.currencyFormatter(for:currencyCode, for: countryCode) {
            amountLabel.attributedText = attributedAmount
        }
    }
    
}
