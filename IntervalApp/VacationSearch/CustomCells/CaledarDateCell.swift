//
//  CaledarDateCell.swift
//  IntervalApp
//
//  Created by Chetu on 10/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class CaledarDateCell: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var dayDateLabel: UILabel!
    @IBOutlet weak var dateWithDateFormatLabel: UILabel!
    @IBOutlet weak var dateMonthYearLabel: UILabel!
    @IBOutlet weak var calendarIconButton: UIButton!
    
    @IBOutlet weak var checkInDayDateLabel: UILabel!
    @IBOutlet weak var checkInDayNameLabel: UILabel!
    @IBOutlet weak var checkInMonthYearLabel: UILabel!
    
    @IBOutlet weak var checkOutDayDateLabel: UILabel!
    @IBOutlet weak var checkOutDayNameLabel: UILabel!
    @IBOutlet weak var checkOutMonthYearLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
