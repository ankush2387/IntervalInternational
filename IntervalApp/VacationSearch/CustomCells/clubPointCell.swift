//
//  clubPointCell.swift
//  IntervalApp
//
//  Created by Chetu on 21/03/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class clubPointCell: UITableViewCell {
    
    @IBOutlet weak var yearLabel: UILabel!

    @IBOutlet weak var addButton: IUIKButton!
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
