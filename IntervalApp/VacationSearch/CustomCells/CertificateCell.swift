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
    @IBOutlet weak var travelWindowStartDateLbl: UILabel!
    @IBOutlet weak var travelWindowStartDayLbl: UILabel!
    @IBOutlet weak var travelWindowStartMonthYearLbl: UILabel!
    @IBOutlet weak var travelWindowEndDateLbl: UILabel!
    @IBOutlet weak var travelWindowEndDayLbl: UILabel!
    @IBOutlet weak var travelWindowEndMonthYearLbl: UILabel!
    @IBOutlet weak var cellBaseView: UIView!
    @IBOutlet weak var certificateNumber: UILabel!
    @IBOutlet weak var bedroomSize: UILabel!
    @IBOutlet weak var expireDate: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var certificateInfoButton: UIButton!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
