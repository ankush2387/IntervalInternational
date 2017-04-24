//
//  TransactionDetailsTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/22/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class TransactionDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var travellingWithLabel: UILabel!
    @IBOutlet weak var cabinNumber:UILabel!
    @IBOutlet weak var cabinDetails:UILabel!
    @IBOutlet weak var transactionDate:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
