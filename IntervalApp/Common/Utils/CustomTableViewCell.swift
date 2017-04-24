//
//  CustomTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 9/1/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var modifyInsuranceButton: UIButton!
    @IBOutlet weak var accomodationCertificateNumber: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
