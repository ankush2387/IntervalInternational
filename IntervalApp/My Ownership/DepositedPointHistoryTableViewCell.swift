//
//  DepositedPointHistoryTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class DepositedPointHistoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var expirationdateLabel: UILabel!
    @IBOutlet weak var depositstatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
