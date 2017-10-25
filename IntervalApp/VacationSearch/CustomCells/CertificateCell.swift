//
//  CertificateCell.swift
//  IntervalApp
//
//  Created by Chetu on 23/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class CertificateCell: UITableViewCell {
    
    
    // Travel Window Outlets...
    
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var monthYearLabel: UILabel!
    
    @IBOutlet weak var cellBaseView: UIView!
    @IBOutlet weak var certificateNumber: UILabel!
    
    @IBOutlet weak var bedroomSize: UILabel!
    @IBOutlet weak var totalSleeps: UILabel!
    
    @IBOutlet weak var expireDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

