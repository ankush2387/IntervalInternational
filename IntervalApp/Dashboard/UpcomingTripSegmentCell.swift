//
//  UpcomingTripSegmentCell.swift
//  IntervalApp
//
//  Created by Chetu-macmini-26 on 05/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class UpcomingTripSegmentCell: UITableViewCell {

  //***** Outlets *****//
  @IBOutlet var resortNameLabel: UILabel!
  @IBOutlet var dayDateLabel: UILabel!
  @IBOutlet var dayNameYearLabel: UILabel!
  @IBOutlet var resortLocationLabel: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        //***** Configure the view for the selected state *****//
    }

}
