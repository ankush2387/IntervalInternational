//
//  RelinquishmentSelectionOpenWeeksCell.swift
//  IntervalApp
//
//  Created by Chetu on 10/01/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class RelinquishmentSelectionOpenWeeksCell: UITableViewCell {
    
    
    //IBOutlets
    @IBOutlet weak var dayAndDateLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var totalWeekLabel: UILabel!
    
    @IBOutlet weak var resortDetailsView: UIView!
    @IBOutlet weak var totalSleepAndPrivate: UILabel!
    @IBOutlet weak var bedroomSizeAndKitchenClient: UILabel!
    @IBOutlet weak var resortName: UILabel!
    @IBOutlet weak var dayandDateLabel: UIView!
    
    @IBOutlet weak var addButton: IUIKButton!
    @IBOutlet weak var savedView: UILabel!
 
    @IBOutlet weak var promLabel: UILabel!
    @IBOutlet weak var promImgView: UIImageView!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var checkBox: IUIKCheckbox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
