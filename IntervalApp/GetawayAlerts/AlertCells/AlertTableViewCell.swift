//
//  AlertTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 8/18/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class AlertTableViewCell: UITableViewCell {
    
    //***** Outlets *****//
    
    @IBOutlet weak var alertStatusButton: IUIKButton!
    @IBOutlet weak var alertNameLabel: UILabel!
    @IBOutlet weak var alertDateLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
