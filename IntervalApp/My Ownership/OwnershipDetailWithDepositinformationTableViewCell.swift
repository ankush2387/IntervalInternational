//
//  OwnershipDetailWithDepositinformationTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/1/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class OwnershipDetailWithDepositinformationTableViewCell: UITableViewCell {

    @IBOutlet weak var depositedInfoLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var weekNumberLabel: UILabel!
    
    @IBOutlet weak var ownershipdetailLabel: UILabel!
    
    @IBOutlet weak var depositInformationlabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    /**
    Configure cell components
    - parameter No parameter :
    - returns : No value is return
    */
    func getCell() {
        
    }
    /**
     update  cell components text
     - parameter No parameter :
     - returns : No value is return
     */
    fileprivate func updateCellComponents() {
        depositInformationlabel.text = Constant.ownershipViewController.ownershipDetailWithDepositinformationTableViewCell.depositedInfoLabelText
    }
    /**
     Configure cell components properties
     - parameter No parameter :
     - returns : No value is return
     */
    fileprivate func setCellComponentsProperties() {
        depositedInfoLabel.textColor = UIColor.white
        depositedInfoLabel.backgroundColor = UIColor(rgb: IUIKColorPalette.active.rawValue)
        dateLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
         weekNumberLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        yearLabel.textColor = UIColor(rgb: IUIKColorPalette.active.rawValue)
        ownershipdetailLabel.textColor = UIColor(rgb: IUIKColorPalette.primary1.rawValue)
        depositInformationlabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryB.rawValue)
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
