//
//  BedroomSizeTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class BedroomSizeTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var bedroomSizelabel: UILabel!
    
    @IBOutlet weak var checkBoxButton: IUIKCheckbox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //MARK:configure cell components
    /**
        Configure Components of cell 
        - parameter bedroomSizeDetailDictionary: Dictionary with String key and String Value
        - returns :No return value.
    */
    func getCell(_ bedroomSizeDetailDictionary:[String:String],index:Int,isChecked:Bool = false){
        updateCell(bedroomSizeDetailDictionary)
        
    }
    /**
    Update Bedroom detail label text
    - parameter bedroomSizeDetailDictionary: Dictionary with String key and String value.
    - returns : No value is return
    */
    fileprivate func updateCell(_ bedroomSizeDetailDictionary : [String:String]){
        /** Update bedroom size label text */
        
        bedroomSizelabel.text = bedroomSizeDetailDictionary["size"] ?? "Test"
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
