//
//  PromotionsCell.swift
//  IntervalApp
//
//  Created by Chetu on 15/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class PromotionsCell: UITableViewCell {
    
    @IBOutlet weak var promotionWebView: UIWebView!
    @IBOutlet weak var promotionTextLabel: UILabel!
    @IBOutlet weak var promotionSelectionCheckBox: IUIKCheckbox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
