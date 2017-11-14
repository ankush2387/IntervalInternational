//
//  GuestCertificatePriceCell.swift
//  IntervalApp
//
//  Created by Chetu on 05/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class GuestCertificatePriceCell: UITableViewCell {
    
    @IBOutlet weak var certificatePriceLabel: UILabel!
    @IBOutlet weak var fractionValue: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
