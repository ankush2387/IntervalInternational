//
//  BedroomTableViewCell.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 8/22/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class BedroomTableViewCell: UITableViewCell {

    @IBOutlet weak var bedroomTitleLabel: UILabel!
    @IBOutlet weak var checkedImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
