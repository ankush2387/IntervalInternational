//
//  CustomHeaderCell.swift
//  TBLDEMO
//
//  Created by Chetu-macmini-26 on 19/01/16.
//  Copyright © 2016 Chetu-macmini-26. All rights reserved.
//

import UIKit
import IntervalUIKit

class CustomHeaderCell: UITableViewCell {
  
  //***** Outlets *****//
  @IBOutlet var alertCounterLabel: UILabel!
  @IBOutlet var headerDetailButton: IUIKButton!
  @IBOutlet var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
    }

}
