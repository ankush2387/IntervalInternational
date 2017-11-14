//
//  ResortInfoTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 6/28/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class ResortInfoTableViewCell: UITableViewCell {
  
    //***** Outlets *****//
    @IBOutlet weak var resortInfoLabel: UILabel!
    @IBOutlet weak var resortInfoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
