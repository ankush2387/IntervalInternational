//
//  ContentCell.swift
//  IntervalApp
//
//  Created by Chetu on 09/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class WhereToGoContentCell: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var sepratorView: UIView!
    @IBOutlet weak var sepratorOr: UILabel!
    @IBOutlet weak var sepratorOrView: UIView!
    @IBOutlet weak var whereTogoTextLabel: UILabel!
    @IBOutlet weak var bedroomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
