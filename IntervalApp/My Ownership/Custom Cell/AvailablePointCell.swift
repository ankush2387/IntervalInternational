//
//  AvailablePointCell.swift
//  IntervalApp
//
//  Created by Chetu on 14/01/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class AvailablePointCell: UITableViewCell {
    
    //Outlets
    
    @IBOutlet weak var availablePointValueLabel: UILabel!

    @IBOutlet weak var borderView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
