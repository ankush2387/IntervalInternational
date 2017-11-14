//
//  UnitDetailCell.swift
//  IntervalApp
//
//  Created by Chetu on 03/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class UnitDetailCell: UITableViewCell {

    @IBOutlet weak var bedroomKitchenLabel: UILabel!
    @IBOutlet weak var sleepLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
