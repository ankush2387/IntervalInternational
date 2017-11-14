//
//  MagazineTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 9/15/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class MagazineTableViewCell: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var magazineImageView: UIImageView!
    @IBOutlet weak var magazineTitle: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
