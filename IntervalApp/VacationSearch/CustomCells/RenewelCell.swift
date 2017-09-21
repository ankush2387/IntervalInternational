//
//  RenewelCell.swift
//  IntervalApp
//
//  Created by CHETUMAC043 on 9/21/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class RenewelCell: UITableViewCell {
    
    
    @IBOutlet weak var renewelImageView: UIImageView!

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var renewelLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
