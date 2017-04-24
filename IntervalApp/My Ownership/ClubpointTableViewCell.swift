//
//  ClubpointTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/1/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class ClubpointTableViewCell: UITableViewCell {

    @IBOutlet weak var clubInfoLabel: UILabel!
    
    @IBOutlet weak var pointInfoLabel: UILabel!
    
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var vacationClubLabel: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    
    
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
        setPropertiesToCellElements()
        updateCellComponentsText()
    }
    //MARK:set properties to elements of cell
    /**
    Apply properties to cell components
    - parameter No parameter :
    - returns : No return value
    */
    fileprivate func setPropertiesToCellElements(){
        clubInfoLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        pointInfoLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        yearLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryA.rawValue)
        vacationClubLabel.textColor = UIColor(rgb: IUIKColorPalette.primaryText.rawValue)
        Helper.applyShadowOnUIView(view: mainView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 1)
    }
    /** 
    Update cell components text
    - parameter No parameter:
    - returns : No value is return
    */
    fileprivate func updateCellComponentsText(){
        clubInfoLabel.text = Constant.ownershipViewController.clubpointTableViewCell.clubInfoLabeltext
        pointInfoLabel.text = Constant.ownershipViewController.clubpointTableViewCell.pointInfoLabelText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
