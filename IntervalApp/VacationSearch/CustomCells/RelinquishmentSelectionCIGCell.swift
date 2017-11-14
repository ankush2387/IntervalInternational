//
//  RelinquishmentSelectionCIGCell.swift
//  IntervalApp
//
//  Created by Chetu on 10/01/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class RelinquishmentSelectionCIGCell: UITableViewCell {
    
    @IBOutlet weak var cigImageView: UIImageView!
    
    @IBOutlet weak var availablePointToolButton: IUIKButton!
    
    @IBOutlet weak var addAvailablePointButton: IUIKButton!
    
    @IBOutlet weak var availablePointValueLabel: UILabel!
  
    @IBOutlet weak var availablePointValueWidth: NSLayoutConstraint!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
