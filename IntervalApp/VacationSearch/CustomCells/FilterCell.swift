//
//  FilterCell.swift
//  IntervalApp
//
//  Created by Chetu on 31/07/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit


class FilterCell: UITableViewCell {
    
    //Outlets
    
    @IBOutlet weak var checkBox: IUIKCheckbox!

    @IBOutlet weak var lblFilterOption: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
