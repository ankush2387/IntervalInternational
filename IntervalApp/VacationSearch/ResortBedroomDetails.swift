//
//  ResortBedroomDetails.swift
//  IntervalApp
//
//  Created by Chetu on 21/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class ResortBedroomDetails: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var getawayPriceLabel: UILabel!
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var sepratorOr: UILabel!
    @IBOutlet weak var exchangeButton: UIButton!
    @IBOutlet weak var numberOfBedroom: UILabel!
    @IBOutlet weak var kitchenLabel: UILabel!
    @IBOutlet weak var totalPrivateLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
