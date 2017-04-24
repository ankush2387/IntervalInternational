//
//  OwnerShipDetailTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 2/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
class OwnerShipDetailTableViewCell: UITableViewCell {

   //Outlets
    @IBOutlet weak var ownerShipimageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var placeCode: UILabel!
    @IBOutlet weak var unitdetailLabel: UILabel!
    @IBOutlet weak var weekDetailLabel: UILabel!
    @IBOutlet weak var weekNumberLabel: UILabel!
    @IBOutlet weak var bedroomDetailLabel: UILabel!
    
    /*** override function aWakefromNib ***/
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    //MARK:get MembershipCell using informations
    /**
        Configure cell components.
    
        - parameter membershipDetailDictionary :  This dictionary is used to update label text.
        - returns : No value is returned.
    */
    func getCell(_ membershipDetailDictionary:[String:String]){
        self.setPropertiesTocellElements()
        updateCell(membershipDetailDictionary)
    }
    //MARK:Update value according to server response
    
    /**
        Update label text.
        - parameter membershipDetailDictionary : Dictionary with String key and String Value.
        - returns : No value is return.
    */
    fileprivate func updateCell(_ membershipDetailDictionary:[String:String]){
        /// update Label text
        
        unitdetailLabel.text = Constant.memberShipViewController.ownerShipDetailTableViewCell.unitdetailLabelText
        weekDetailLabel.text = Constant.memberShipViewController.ownerShipDetailTableViewCell.weekDetailLabelText
        
        placeNameLabel.text = membershipDetailDictionary["placename"] ?? ""
        placeAddressLabel.text = membershipDetailDictionary["placeaddress"] ?? ""
        placeCode.text = membershipDetailDictionary["placecode"] ?? ""
        bedroomDetailLabel.text = membershipDetailDictionary["bedroomdetail"] ?? ""
        weekNumberLabel.text = membershipDetailDictionary["weeknumber"] ?? ""
        
        
    }
    //MARK:set commonPrperties to cell
    /** 
    Set  properties to Cell components
    - parameter No parameter:
    - returns : No return value
    */
    fileprivate func setPropertiesTocellElements(){
        //Configure label TextColor
        placeAddressLabel.textColor = UIColor(rgb:IUIKColorPalette.primaryText.rawValue)
        placeCode.textColor = UIColor(rgb:IUIKColorPalette.secondaryB.rawValue)
        unitdetailLabel.textColor = UIColor(rgb:IUIKColorPalette.secondaryText.rawValue)
        weekDetailLabel.textColor = UIColor(rgb:IUIKColorPalette.secondaryText.rawValue)
        bedroomDetailLabel.textColor = UIColor(rgb:IUIKColorPalette.primaryText.rawValue)
        weekNumberLabel.textColor = UIColor(rgb:IUIKColorPalette.primaryText.rawValue)
    }
    
    /*** override setSelected function */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
