//
//  CheckInCheckOutTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 4/4/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class CheckInCheckOutTableViewCell: UITableViewCell {

    @IBOutlet weak var checkindateInformationLabel: UILabel!
    
    @IBOutlet weak var checkinDayLabel: UILabel!
    
    @IBOutlet weak var checkIndateDetailLabel: UILabel!
    
    @IBOutlet weak var checkOutDateInformationLabel: UILabel!
    
    @IBOutlet weak var checkoutDayLabel: UILabel!
    
    
    @IBOutlet weak var checkoutDateDetailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
