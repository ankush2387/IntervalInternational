//
//  RelinquishmentSelectionOpenWeeksCell1.swift
//  IntervalApp
//
//  Created by Chetu on 06/07/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class RelinquishmentSelectionOpenWeeksCell1: UITableViewCell {
    
    //IBOutlets
    @IBOutlet weak var dayAndDateLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var totalWeekLabel: UILabel!
    @IBOutlet weak var totalSleepAndPrivate: UILabel!
    @IBOutlet weak var bedroomSizeAndKitchenClient: UILabel!
    @IBOutlet weak var resortName: UILabel!
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var lblFees: UILabel!
    @IBOutlet weak var checkBox: IUIKCheckbox!

    @IBOutlet weak var lblUpgrade: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
