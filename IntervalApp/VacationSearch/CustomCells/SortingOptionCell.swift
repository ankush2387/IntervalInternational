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
    @IBOutlet weak var sortingOptionLabel: UILabel!
    
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
