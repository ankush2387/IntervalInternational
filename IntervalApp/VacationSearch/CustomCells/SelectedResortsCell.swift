//
//  SelectedResortsCell.swift
//  IntervalApp
//
//  Created by ChetuMac-007 on 04/09/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class SelectedResortsCell: UITableViewCell {
    
    @IBOutlet weak var lblResortsName: UILabel!

    @IBOutlet weak var lblResortsCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
