//
//  ClubresortTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/3/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class ClubresortTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var clubresortNameLabel: UILabel!
    
    @IBOutlet weak var clubresortAvailabilitylabel: UILabel!
    
    @IBOutlet weak var clubResortCheckbox: IUIKCheckbox!
    
    //Class Variables
    var clubresortDictionary = [String:String]()
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    /**
    Configure Cell components
    - parameter clubresortdictionary : Dictionary with String key and String Value
    - returns : No value is return
    */
    func getCell(index:Int,isChecked:Bool = false){
        //self.clubresortDictionary = clubresortdictionary
        clubResortCheckbox.tag = index
        clubResortCheckbox.checked = isChecked
        intervalPrint(Constant.MyClassConstants.savedBedroom)
        if(isChecked || Constant.MyClassConstants.savedClubFloatResort == Constant.MyClassConstants.clubFloatResorts[index].resortName!){
            clubresortNameLabel.textColor = UIColor.orange
            clubResortCheckbox.checked = true
        }else{
            clubresortNameLabel.textColor = UIColor.black
            clubResortCheckbox.checked = false
        }
    }
    
    func getBedroomCell(index:Int,isChecked:Bool = false){
        //self.clubresortDictionary = clubresortdictionary
        clubResortCheckbox.tag = index
        clubResortCheckbox.checked = isChecked
        intervalPrint(Constant.MyClassConstants.savedBedroom)
        if(isChecked || Constant.MyClassConstants.savedBedroom == UnitSize.forDisplay[index].rawValue){
            clubresortNameLabel.textColor = UIColor.orange
            clubResortCheckbox.checked = true
        }else{
            clubresortNameLabel.textColor = UIColor.black
            clubResortCheckbox.checked = false
        }
    }
    /**
     Apply properties to cell components
     - parameter No parameter :
     - returns : No return value
     */
    fileprivate func setPropertiesToCellElements(){
        clubresortNameLabel.textColor = UIColor(rgb: IUIKColorPalette.primary1.rawValue)
        //clubresortAvailabilitylabel.textColor = UIColor(rgb: IUIKColorPalette.primary1.rawValue)

    }

    /**
     Update label text
     - parameter No parameter :
     - returns : No value is return
     */
    fileprivate func updateCellComponent(){
       /* if let clubresortname = clubresortDictionary["clubresortname"]{
            clubresortNameLabel.text = clubresortname
        }
        if let clubresoravailabilty = clubresortDictionary["clubresoravailabilty"]{
            clubresortAvailabilitylabel.text = clubresoravailabilty
        }*/
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
