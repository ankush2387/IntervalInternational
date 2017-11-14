//
//  SlideTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 11/22/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class SlideTableViewCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var feesTitleLabel: UILabel!
    @IBOutlet weak var agreeLabel: UILabel!
    @IBOutlet weak var agreeButton: MMSlidingButton?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        agreeLabel.layer.borderColor = UIColor.orange.cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
