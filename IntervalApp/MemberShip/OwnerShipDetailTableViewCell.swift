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
        placeCode.text = ownership.resort?.resortCode?.localized()
        let bedroomSize = Helper.getBedroomNumbers(bedroomType: ownership.unit?.unitSize ?? "")
        //bedroomDetailLabel.text = bedroomSize.localized()
        bedroomDetailLabel.text = ownership.unit?.unitNumber
        weekNumberLabel.text = ownership.weekNumber?.localized()
        if let images = ownership.resort?.images {
            var imageURLStr = ""
            if images.count > 1 {
                 imageURLStr = images[1].url ?? ""
            } else if !images.isEmpty {
                 imageURLStr = images[0].url ?? ""
            }
            ownerShipimageView.setImageWith(URL(string: imageURLStr), completed: { (image:UIImage?, error:Swift.Error?, _:SDImageCacheType, _:URL?) in
                if error != nil {
                    self.ownerShipimageView.image = UIImage(named: Constant.MyClassConstants.noImage)
                }
            }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        }
        if let weekNumber = ownership.weekNumber {
            switch weekNumber {
            case "POINTS_WEEK":
                weekNumberLabel.text = "\(Constant.getPointWeek(weektype: ownership.weekNumber ?? ""))".localized()
            case "FLOAT_WEEK":
                weekNumberLabel.text = "\(Constant.getFlotWeek(weekType: ownership.weekNumber ?? ""))".localized()
            default:
                weekNumberLabel.text = "\(Constant.getWeekNumber(weekType: ownership.weekNumber ?? ""))".localized()
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
