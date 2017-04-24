//
//  OwnershipDetailWithFreeDepositTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/1/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class OwnershipDetailWithFreeDepositTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var weekNumberLabel: UILabel!
    
    @IBOutlet weak var depositForFreeButton: UIButton!
    
    @IBOutlet weak var ownershipdetails: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var mainViewBottomConstraint: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //MARK:get cell
    /**
    Configure Cell components
    - parameter No parameter :
    - returns : No return value
    */
    func getCell(){
        self.setPropertiesToCellElements()
    }
    //MARK:set properties to elements of cell
    /**
    Apply properties to cell components
    - parameter No parameter :
    - returns : No return value
    */
    fileprivate func setPropertiesToCellElements(){
        dateLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        weekNumberLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        yearLabel.textColor = UIColor(rgb: IUIKColorPalette.active.rawValue)
        Helper.applyShadowOnUIView(view: mainView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 1.0)
    }
    /**
    Update cell components text
    - parameter No parameter:
    - returns : No value is return
    */
    fileprivate func updateCellComponentsText(){
        depositForFreeButton.setTitle(Constant.ownershipViewController.ownershipDetailWithFreeDepositTableViewCell.depositForFreeButtonTitle, for: UIControlState())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
