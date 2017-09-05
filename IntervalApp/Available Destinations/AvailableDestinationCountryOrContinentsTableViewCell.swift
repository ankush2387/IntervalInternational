//
//  AvailableDestinationCountryOrContinentsTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/14/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class AvailableDestinationCountryOrContinentsTableViewCell: UITableViewCell {

    @IBOutlet weak var tooglebutton: UIButton!
    
    @IBOutlet weak var countryOrContinentLabel: UILabel!
    
    @IBOutlet weak var selectdDestinationCountLabel: UILabel?
    
    @IBOutlet weak var expandRegionButton: UIButton!
    

   
    @IBOutlet weak var imgIconPlus: UIImageView?
        
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectdDestinationCountLabel?.layer.cornerRadius = 10
        self.selectdDestinationCountLabel?.layer.masksToBounds = true
        // Initialization code
    }
    /**
    Configure cell
    - parameter No parameter :
    - returns : No value is return
    */
    
    func getCell(_ index:Int,islistOfCountry:Bool = false,selectedPlaceDictionary:[Int:Bool] = [Int:Bool]()){
        if islistOfCountry{
            tooglebutton.setImage(UIImage(named: Constant.assetImageNames.upArrowImage), for: UIControlState())
        }
        else{
            tooglebutton.setImage(UIImage(named: Constant.assetImageNames.dropArrow), for: UIControlState())

        }
        tooglebutton.tag = index
        //selectdDestinationCountLabel.tag = index
        //selectdDestinationCountLabel.text = String(selectedPlaceDictionary.count)
        setPropertiesToCellComponents()
        
    }
    /**
    Set properties to cell components
    - parameter No parameter:
    - returns : No value is return
    */
    fileprivate func setPropertiesToCellComponents(){
        //selectdDestinationCountLabel.layer.cornerRadius = selectdDestinationCountLabel.bounds.size.width/2
       // selectdDestinationCountLabel.layer.masksToBounds = true
       // selectdDestinationCountLabel.backgroundColor = UIColor(rgb:IUIKColorPalette.Alert.rawValue)
    }
    func setDataForAllAvailableDestinations(index:Int){
        guard let region = Constant.MyClassConstants.regionArray[index].regionName else {
            return
        }
        countryOrContinentLabel.text = region
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
