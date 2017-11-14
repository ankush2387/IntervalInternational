//
//  PolicyCell.swift
//  IntervalApp
//
//  Created by Chetu on 03/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class PolicyCell: UITableViewCell {
    
    @IBOutlet weak var purchasePolicyButton: UIButton!
    @IBOutlet weak var policyLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
