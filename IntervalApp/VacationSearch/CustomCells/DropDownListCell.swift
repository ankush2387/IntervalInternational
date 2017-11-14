//
//  DropDownListCell.swift
//  IntervalApp
//
//  Created by Chetu on 04/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class DropDownListCell: UITableViewCell {
    
    //Outlets
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var selectedTextLabel: UILabel!
    @IBOutlet weak var dropDownButton: IUIKButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
