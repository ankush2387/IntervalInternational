//
//  RelinquishmentDetailsCell.swift
//  IntervalApp
//
//  Created by Chetu on 14/07/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class RelinquishmentDetailsCell: UITableViewCell {

    @IBOutlet weak var resortImage: UIImageView!
    
    @IBOutlet weak var resortName: UILabel!
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var resortCode: UILabel!
    @IBOutlet weak var resortCountry: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
