//
//  AvailablePointsPointsAsOfTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/16/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class AvailablePointsAsOfTableViewCell: UITableViewCell {

    @IBOutlet weak var pointasOflabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    /**
    Configure cell
    - parameter No parameter:
    - returns : No value is return
    */
    func getCell(){
        setPropertiesToCellElements()
        updateCellComponetstext()
    }
    //MARK:set properties to elements of cell
    /**
    Apply properties to cell components
    - parameter No parameter :
    - returns : No return value
    */
    fileprivate func setPropertiesToCellElements(){
        pointasOflabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
         pointasOflabel.textColor = UIColor(rgb: IUIKColorPalette.primary1.rawValue)
    }
    /**
     Update Cell components Text
     - parameter No parameter :
     - returns : No return value
     */
    fileprivate func updateCellComponetstext(){
        pointasOflabel.text = Constant.availablePointToolViewController.availablePointsAsOfTableViewCell.pointasOflabelText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
