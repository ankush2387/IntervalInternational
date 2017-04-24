//
//  DummyTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 4/20/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class DummyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var switchMembershipButton: UIButton!
    
    @IBOutlet weak var memberNumberLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
