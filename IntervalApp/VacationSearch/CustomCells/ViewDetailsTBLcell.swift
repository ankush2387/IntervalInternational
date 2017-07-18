//
//  ViewDetailsTBLcell.swift
//  IntervalApp
//
//  Created by Chetu on 03/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class ViewDetailsTBLcell: UITableViewCell {

    @IBOutlet weak var resortDetailsButton: IUIKButton!
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var resortImageView: UIImageView?
    @IBOutlet weak var resortName: UILabel?
    @IBOutlet weak var resortAddress:UILabel?
    @IBOutlet weak var resortCode:UILabel?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
