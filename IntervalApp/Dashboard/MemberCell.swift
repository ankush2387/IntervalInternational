//
//  MemberCell.swift
//  IntervalApp
//
//  Created by Chetu-macmini-26 on 05/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class MemberCell: UITableViewCell {

    //***** Outlets *****//
  @IBOutlet var iconImageView: UIImageView!
  @IBOutlet var customTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
         //***** Initialization code *****//
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        //***** Configure the view for the selected state *****//
    }
    
}
