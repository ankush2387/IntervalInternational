//
//  SaveCardOptionCell.swift
//  IntervalApp
//
//  Created by Chetu on 19/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class SaveCardOptionCell: UITableViewCell {
    
    @IBOutlet weak var saveThisCardCheckBox: IUIKCheckbox!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
