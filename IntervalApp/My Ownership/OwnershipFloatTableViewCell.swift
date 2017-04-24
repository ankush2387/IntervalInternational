//
//  OwnershipFloatTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/1/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class OwnershipFloatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var floatInfoLabel: UILabel!
    
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var mainViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var upperHorizontalSeperator: UIView!
    
    @IBOutlet weak var lowerHorizontalSeperator: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    /**
     Configure cell
     - parameter No parameter:
     - returns : No value is return
     */
    func getCell(isConstraintUpdate:Bool){
        setCellComponentsProperties()
        updateCellComponents()
        if isConstraintUpdate{
            mainViewBottomConstraint.constant = 10
            lowerHorizontalSeperator.isHidden = true
            upperHorizontalSeperator.isHidden = true
        }
    }
    /**
     update  cell components text
     - parameter No parameter :
     - returns : No value is return
     */
    fileprivate func updateCellComponents(){
        floatInfoLabel.text = Constant.ownershipViewController.ownershipFloatTableViewCell.floatInfoLabelText
    }
    /**
     Configure cell components properties
     - parameter No parameter :
     - returns : No value is return
     */
    fileprivate func setCellComponentsProperties(){
        
        floatInfoLabel.textColor = UIColor(rgb: IUIKColorPalette.active.rawValue)
        yearLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        Helper.applyShadowOnUIView(view: mainView, shadowcolor: UIColor.black, shadowopacity: 0.4, shadowradius: 1.0)
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
