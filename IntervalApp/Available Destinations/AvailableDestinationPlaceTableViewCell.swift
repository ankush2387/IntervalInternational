//
//  AvailableDestinationPlaceTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/14/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
class AvailableDestinationPlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var placeSelectionCheckBox: IUIKCheckbox!
    @IBOutlet weak var tdiImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    /**
     Configure cell
     - parameter No parameter :
     - returns : No value is return
     */
    
    func getCell(_ indexpath:IndexPath,selectedPlaceDictionary:[Int:Bool] = [Int:Bool]()){
        
    }
    
    func setAllAvailableAreaCell(index:Int, area:RegionArea){
        infoLabel.text = area.areaName
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
