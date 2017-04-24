//
//  VacationDetailTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/3/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class VacationDetailTableViewCell: UITableViewCell {

    //Outlets
    
    @IBOutlet weak var vacationNameLabel: UILabel!
    
    @IBOutlet weak var vacationAddressLabel: UILabel!
    
    @IBOutlet weak var vacationCodeLabel: UILabel!
    
    @IBOutlet weak var vacationImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //MARK:get cell
    /**
    Configure Cell components
    - parameter No parameter:
    - returns : No return value
    */
    func getCell(){
        setPropertiesTocellComponenet()
        updateCellComponentstext()
    }
    //MARK:set properties to cell component
    /** 
    Apply Properties to cell components
    - parameter No parameter:
    - returns : No return value
    */
    fileprivate func setPropertiesTocellComponenet(){
        vacationNameLabel.textColor = UIColor(rgb: IUIKColorPalette.primary1.rawValue)
        vacationAddressLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        vacationCodeLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryB.rawValue)
    }
    /**
    Update cell componets text
    - parameter No parameter:
    - returns : No value is return
    */
    fileprivate func updateCellComponentstext(){
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
