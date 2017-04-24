//
//  AdvisementsCell.swift
//  IntervalApp
//
//  Created by Chetu on 15/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class AdvisementsCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var advisementType: UILabel!
    @IBOutlet weak var advisementTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
