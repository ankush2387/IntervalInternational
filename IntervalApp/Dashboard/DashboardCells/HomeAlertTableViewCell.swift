//
//  HomeAlertTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 9/7/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class HomeAlertTableViewCell: UITableViewCell {
    
    @IBOutlet var alertTitleLabel: UILabel!
    @IBOutlet var alertDateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
