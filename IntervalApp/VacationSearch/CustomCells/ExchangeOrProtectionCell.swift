//
//  ExchangeOrProtectionCell.swift
//  IntervalApp
//
//  Created by Chetu on 16/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class ExchangeOrProtectionCell: UITableViewCell {
    
    //Outlets
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var additionalPriceLabel: UILabel!
    @IBOutlet weak var primaryPriceLabel: UILabel!
    @IBOutlet weak var fractionalPriceLabel: UILabel!
    @IBOutlet weak var additionalPrimaryPriceLabel: UILabel!
    @IBOutlet weak var additionalFractionalPriceLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
