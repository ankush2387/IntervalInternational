//
//  PaymentCell.swift
//  IntervalApp
//
//  Created by Chetu on 03/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {
    
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak var balanceDueLabel: UILabel!
    @IBOutlet weak var balanceDueDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
