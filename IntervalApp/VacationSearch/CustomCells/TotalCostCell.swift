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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
