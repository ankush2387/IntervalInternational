//
//  FloatSaveAndCancelButtonTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/15/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class FloatSaveAndCancelButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var saveFloatDetailButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    /**
    Configure cell
    - parameter No parameter:
    - returns : No value is return
    */
    func getCell() {
        
    }
    /**
    Set properties to cell Components
    - parameter No parameter:
    - returns : No value is return
    */
    fileprivate func setPropertiesToCellComponents() {
        saveFloatDetailButton.tintColor = UIColor.white
        saveFloatDetailButton.backgroundColor = UIColor(rgb: IUIKColorPalette.secondaryA.rawValue)
        cancelButton.tintColor = UIColor(rgb: IUIKColorPalette.primary1.rawValue)
        cancelButton.backgroundColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        
    }
    /** 
    Update cell components text
    - parameter No parameter:
    - returns : No value is return
    */
    fileprivate func updateCellComponetsText() {
        saveFloatDetailButton.setTitle(Constant.floatDetailViewController.floatSaveAndCancelButtonTableViewCell.saveFloatDetailButtonTitle, for: UIControlState())
        cancelButton.setTitle(Constant.buttonTitles.cancel, for: UIControlState())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
