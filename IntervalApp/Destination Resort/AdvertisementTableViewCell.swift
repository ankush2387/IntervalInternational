//
//  AdvertisementTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 4/1/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class AdvertisementTableViewCell: UITableViewCell {

    @IBOutlet weak var importantAdvertisementInformationLabel: UILabel!
    
    @IBOutlet weak var importantAdvertisementDetailLabel: UILabel!
    
    @IBOutlet weak var generalAdvertisementInformationLabel: UILabel!
    
    @IBOutlet weak var generalAdvertisementDetailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
