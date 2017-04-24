//
//  UnitdetailTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 4/1/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class UnitdetailTableViewCell: UITableViewCell {

    @IBOutlet weak var unitDetailInformationLabel: UILabel!
    
    @IBOutlet weak var bedroomDetailLabel: UILabel!
    
    @IBOutlet weak var sleepDetails: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
