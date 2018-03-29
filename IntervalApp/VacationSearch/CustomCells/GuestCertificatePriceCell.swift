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

    func setPrice(with currencyCode: String, and chargeAmount: Float, and countryCode: String?) {
        if let attributedAmount = chargeAmount.currencyFormatter(for:currencyCode, for: countryCode, baseLineOffSet: 7) {
            certificatePriceLabel.attributedText = attributedAmount
        }
    }

}
