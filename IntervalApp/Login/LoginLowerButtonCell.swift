//
//  LoginLowerButtonCell.swift
//  IntervalApp
//
//  Created by Chetu-macmini-26 on 28/01/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class LoginLowerButtonCell: UITableViewCell {
  
  //***** Outlets *****//
  @IBOutlet var resortDirectory: IUIKButton!
  @IBOutlet var magazines: IUIKButton!
  @IBOutlet var intervalHD: IUIKButton!

    @IBOutlet weak var buildVersion: UILabel!
    @IBOutlet weak var buttonBackgroundView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.9)//UIColor(white: 255/255, alpha: 0.7)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        resortDirectory .setTitle(Constant.buttonTitles.resortTitle, for: .normal)
        intervalHD.setTitle(Constant.buttonTitles.intervalHDTitle, for: .normal)
        magazines.setTitle(Constant.buttonTitles.magazineTitle, for: .normal)
        //***** Configure the view for the selected state *****//
    }

}
