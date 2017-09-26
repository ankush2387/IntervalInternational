//
//  AvailablePointCell.swift
//  IntervalApp
//
//  Created by Chetu on 14/01/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class AvailablePointCell: UITableViewCell {
    
    //Outlets
    
    @IBOutlet weak var availablePointValueLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
   
    @IBOutlet weak var checkBOx: IUIKCheckbox!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
