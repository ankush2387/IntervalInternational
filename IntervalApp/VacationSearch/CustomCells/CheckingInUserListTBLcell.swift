//
//  CheckingInUserListTBLcell.swift
//  IntervalApp
//
//  Created by Chetu on 03/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class CheckingInUserListTBLcell: UITableViewCell {
    
    
    @IBOutlet weak var contentBorderView: UIView!
    @IBOutlet weak var checkBox: IUIKCheckbox!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
