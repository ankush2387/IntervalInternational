//
//  MyownershipClubIntervalGoldPointsTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/21/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class MyownershipClubIntervalGoldPointsTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var pointsinfoLabel: UILabel!
    
    @IBOutlet weak var asOfPointsinfoLabel: UILabel!
    
    @IBOutlet weak var totalPointLabel: UILabel!
    
    @IBOutlet weak var clubintervalGoldPointsMainView: UIView!
    
    
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
        updateCellComponentsText()
    }
    //MARK:set properties to elements of cell
    /**
    Apply properties to cell components
    - parameter No parameter :
    - returns : No return value
    */
    fileprivate func setPropertiesToCellElements(){
        
        Helper.applyCornerRadious(view: clubintervalGoldPointsMainView, cornerradious: Constant.viewProperties.cornerRadious)
        Helper.applyShadowOnUIView(view: clubintervalGoldPointsMainView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 2)
        pointsinfoLabel.textColor = UIColor(rgb: IUIKColorPalette.primaryText.rawValue)
        asOfPointsinfoLabel.textColor = UIColor(rgb:IUIKColorPalette.secondaryText.rawValue)
        totalPointLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryB.rawValue)
    }
    /**
     Update cell components text
     - parameter No parameter:
     - returns : No value is return
     */
    fileprivate func updateCellComponentsText(){
        
        pointsinfoLabel.text = Constant.ownershipViewController.clubIntervalAvailableGoldPointTableViewCell.pointsinfoLabelText
        asOfPointsinfoLabel.text = Constant.ownershipViewController.clubIntervalAvailableGoldPointTableViewCell.asOfPointsinfoLabelText
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
