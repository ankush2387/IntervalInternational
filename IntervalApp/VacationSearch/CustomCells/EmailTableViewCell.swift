//
//  EmailTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 12/8/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class EmailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var updateEmailOnOffSwitch: UISwitch!
    
    @IBOutlet weak var inputClearButton: UIButton!
    @IBOutlet weak var updateProfileTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
