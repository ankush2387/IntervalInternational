//
//  ResortDetailCellTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 4/1/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class ResortDetailCellTableViewCell: UITableViewCell {

    @IBOutlet weak var resortImageView: UIImageView!
    
    @IBOutlet weak var resortNameLabel: UILabel!
    
    @IBOutlet weak var resortPlaceLabel: UILabel!
    
    @IBOutlet weak var resortCodeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    /**
    Configure cell components
    - parameter No Parameter:
    - returns : No value is return
    */
    func getCell() {
        setProperties()
        updateCellComponentsText()
    }
    /**
    Set Properties to cell Components
    - parameter No parameter :
    - returns : No value is return
    */
    private func setProperties() {
        resortNameLabel.textColor = UIColor(rgb: IUIKColorPalette.PrimaryText.rawValue)
        resortPlaceLabel.textColor = UIColor(rgb: IUIKColorPalette.PrimaryText.rawValue)

        resortCodeLabel.textColor = UIColor(rgb: IUIKColorPalette.SecondaryB.rawValue)
    }
    /**
    Update cell components text
    - parameter No parameter:
    - returns : No value is return
    */
    private func updateCellComponentsText() {
        resortNameLabel.text = "Hayat Vacation resorts"
        resortPlaceLabel.text = "Jupitar,FL"
        resortCodeLabel.text = "JBS"
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
