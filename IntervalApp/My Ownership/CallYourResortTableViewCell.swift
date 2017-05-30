//
//  CallYourResortTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/3/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
class CallYourResortTableViewCell: UITableViewCell {

    /** Outlets */
    @IBOutlet weak var callresortbutton: UIButton!
    @IBOutlet weak var donothaveresortLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    //MARK:get cell
    /**
    Configure Cell components
    - parameter No parameter:
    - returns : No return value
    */
    func getCell(){
        setPropertiesTocellComponenet()
    }
    //MARK:set properties to cell component
    /**
    Apply Properties to cell components
    - parameter No parameter:
    - returns : No return value
    */
    fileprivate func setPropertiesTocellComponenet(){
        
        callresortbutton.layer.cornerRadius = 8
        callresortbutton.tintColor = UIColor.white
        callresortbutton.backgroundColor = UIColor.green
        donothaveresortLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
    }
    /**
     Update cell components text
     - parameter No parameter:
     - returns : No return value
     */
    fileprivate func updateCellComponentsText(){
        callresortbutton.setTitle(Constant.floatDetailViewController.callYourResortTableViewCell.callresortbuttonTitle, for: UIControlState())
        donothaveresortLabel.text = Constant.floatDetailViewController.callYourResortTableViewCell.donothaveresortLabelText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
