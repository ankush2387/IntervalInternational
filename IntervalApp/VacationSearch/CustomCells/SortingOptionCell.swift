//
//  SortingOptionCell.swift
//  IntervalApp
//
//  Created by Chetu on 20/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class SortingOptionCell: UITableViewCell {
    
    //Outlets
    
    @IBOutlet weak var lblSortingRange: UILabel!
    @IBOutlet weak var checkBox: IUIKCheckbox!
    
    @IBOutlet weak var lblSortingOption: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
