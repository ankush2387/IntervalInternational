//
//  PromotionsDiscountCell.swift
//  IntervalApp
//
//  Created by Chetu on 16/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class PromotionsDiscountCell: UITableViewCell {
    
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var centsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
