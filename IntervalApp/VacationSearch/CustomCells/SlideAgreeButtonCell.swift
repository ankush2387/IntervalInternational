//
//  SlideAgreeButtonCell.swift
//  IntervalApp
//
//  Created by Chetu on 18/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class SlideAgreeButtonCell: UITableViewCell {
    
    @IBOutlet weak var sliderView: UIView!
    
    @IBOutlet weak var agreeAndPayButton: IUIKButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
