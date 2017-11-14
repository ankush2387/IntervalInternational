//
//  FloatDetailsCheckIndateTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/15/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class FloatDetailsCheckIndateTableViewCell: UITableViewCell {

    @IBOutlet weak var checkInDateInformationLabel: UILabel!
    
    @IBOutlet weak var checkInDateDetailLabel: UILabel!
    
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
    Set properties to cell components
    - parameter No parameter:
    - returns : No value is return
    */
    fileprivate func setPropertiesToCellComponents() {
        checkInDateInformationLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        checkInDateDetailLabel.textColor = UIColor(rgb: IUIKColorPalette.primary1.rawValue)
        
    }
    /**
    Update cell components  
    - parameter No parameter:
    - returns : No value is return
    */
    fileprivate func updateCellComponetsText() {
        checkInDateInformationLabel.text = Constant.floatDetailViewController.floatDetailsCheckIndateTableViewCell.checkInDateInformationLabelText
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
