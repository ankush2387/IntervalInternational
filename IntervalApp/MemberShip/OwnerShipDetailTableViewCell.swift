//
//  OwnerShipDetailTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 2/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import SDWebImage
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
    // MARK: get MembershipCell using informations
    func getCell(ownership: Ownership) {
        self.setPropertiesTocellElements()
        updateCell(ownership: ownership)
    }
    // MARK: Update value according to server response
    fileprivate func updateCell(ownership: Ownership) {
        // update Label text
        placeNameLabel.text = ownership.resort?.resortName
        placeAddressLabel.text = ownership.resort?.address?.cityName
        if let state = ownership.resort?.address?.territoryCode {
            placeAddressLabel.text?.append(", \(state)")
        }
        if let countryCode = ownership.resort?.address?.countryCode {
            placeAddressLabel.text?.append(", \(countryCode)")
        }
        placeCode.text = ownership.resort?.resortCode
        let bedroomSize = Helper.getBedroomNumbers(bedroomType: (ownership.unit?.unitSize)!)
        bedroomDetailLabel.text = bedroomSize
        weekNumberLabel.text = ownership.weekNumber
        if((ownership.resort?.images.count)! > 0) {
            let imageURLStr = ownership.resort?.images[1].url
            ownerShipimageView.setImageWith(URL(string: imageURLStr!), completed: { (image:UIImage?, error:Swift.Error?, _:SDImageCacheType, _:URL?) in
                if (error != nil) {
                    self.ownerShipimageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                }
            }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)

        if ownership.weekNumber == "POINTS_WEEK" {
            
            weekNumberLabel.text = Constant.getPointWeek(weektype: ownership.weekNumber!)
            
        } else if ownership.weekNumber == "FLOAT_WEEK"{
            
            weekNumberLabel.text = Constant.getFlotWeek(weekType: ownership.weekNumber!)
        } else {
           weekNumberLabel.text = "Week \(Constant.getWeekNumber(weekType: ownership.weekNumber!))"
        }
    }
}
    
    // MARK: set commonPrperties to cell
    fileprivate func setPropertiesTocellElements() {
        //Configure label TextColor
        placeAddressLabel.textColor = UIColor(rgb: IUIKColorPalette.primaryText.rawValue)
        placeCode.textColor = UIColor(rgb: IUIKColorPalette.secondaryB.rawValue)
        unitdetailLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        weekDetailLabel.textColor = UIColor(rgb: IUIKColorPalette.secondaryText.rawValue)
        bedroomDetailLabel.textColor = UIColor(rgb: IUIKColorPalette.primaryText.rawValue)
        weekNumberLabel.textColor = UIColor(rgb: IUIKColorPalette.primaryText.rawValue)
    }
    
    /*** override setSelected function */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
