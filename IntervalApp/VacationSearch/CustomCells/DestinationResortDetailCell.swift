//
//  DestinationResortDetailCell.swift
//  IntervalApp
//
//  Created by Chetu on 07/04/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class DestinationResortDetailCell: UITableViewCell {

    @IBOutlet weak var contentBackgroundView: UIView!
    @IBOutlet weak var destinationImageView: UIImageView!
    @IBOutlet weak var resortName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
