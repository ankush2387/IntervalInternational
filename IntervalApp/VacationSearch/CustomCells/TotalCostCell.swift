//
//  TotalCostCell.swift
//  IntervalApp
//
//  Created by Chetu on 16/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class TotalCostCell: UITableViewCell {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var fractionalPriceLabel: UILabel!
    @IBOutlet weak var currencyCodeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func setTotalPrice(with currencyDisplayes: String, and chargeAmount: Float) {
        
        if let attributedAmount = chargeAmount.currencyFormatter(for:currencyDisplayes) {
            amountLabel.attributedText = attributedAmount
        }
    }
}
