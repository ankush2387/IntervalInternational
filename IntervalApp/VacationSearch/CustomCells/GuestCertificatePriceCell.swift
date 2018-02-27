//
//  GuestCertificatePriceCell.swift
//  IntervalApp
//
//  Created by Chetu on 05/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class GuestCertificatePriceCell: UITableViewCell {
    
    @IBOutlet weak var certificatePriceLabel: UILabel!
    @IBOutlet weak var fractionValue: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setPrice(with currencyDisplayes: String, and chargeAmount: Float) {
        
        if let attributedAmount = chargeAmount.currencyFormatter(for:currencyDisplayes) {
            certificatePriceLabel.attributedText = attributedAmount
        }
    }

}
