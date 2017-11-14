//
//  OwnershipDetailTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/1/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class OwnershipDetailTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var weekLabel: UILabel!
    
    @IBOutlet weak var detaillabel: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var mainViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var upperHorizontalSeperator: UIView!
    
    @IBOutlet weak var lowerHorizontalSeperator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: get cell
    /**
    Configure Cell components
    - parameter No parameter :
    - returns : No return value
    */
    func getCell(_ isConstraintUpdate: Bool = false) {
        setPropertiesToCellElements()
        updateCellComponentsText()
        if isConstraintUpdate {
            mainViewBottomConstraint.constant = 10
            lowerHorizontalSeperator.isHidden = true
        } else {
            lowerHorizontalSeperator.isHidden = true
        }
    }
    // MARK: set properties to elements of cell
    /**
    Apply properties to cell components
    - parameter No parameter :
    - returns : No return value
    */
    fileprivate func setPropertiesToCellElements() {
        dateLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        weekLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        yearLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryA.rawValue)
        detaillabel.textColor = UIColor(rgb: IUIKColorPalette.primary1.rawValue)
        Helper.applyShadowOnUIView(view: mainView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 1)
    }
    /** 
    Update cellcomponents text
    - parameter No parameter:
    - returns : No value is return
    */
    fileprivate func updateCellComponentsText() {
        //Dummy Data 
        dateLabel.text = "Dec 20"
        yearLabel.text = "2016"
        weekLabel.text = "Week 29"
        detaillabel.text = "2 Bedroom,Full Kitchen \n Sleeps 6 total , 4 Private"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
