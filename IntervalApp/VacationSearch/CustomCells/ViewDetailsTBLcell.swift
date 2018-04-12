//
//  ViewDetailsTBLcell.swift
//  IntervalApp
//
//  Created by Chetu on 03/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class ViewDetailsTBLcell: UITableViewCell {

    @IBOutlet weak var resortDetailsButton: IUIKButton!
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var resortImageView: UIImageView?
    @IBOutlet weak var resortName: UILabel?
    @IBOutlet weak var resortAddress: UILabel?
    @IBOutlet weak var resortCode: UILabel?
    @IBOutlet weak var labelFirstHeading: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpDetailsCell (indexPath: IndexPath, filterRelinquishments: ExchangeRelinquishment) {
        if indexPath.row == 0 {
            resortDetailsButton.tag = indexPath.row
            lblHeading.text = "Resort Detail".localized()
            if let selectedResort = Constant.MyClassConstants.selectedAvailabilityResort {
                resortName?.text = selectedResort.name
            } else {
                resortName?.text = ""
            }
        } else {
            
            if let openWeek = filterRelinquishments.openWeek {
                resortName?.text = openWeek.resort?.resortName
                lblHeading.text = Constant.MyClassConstants.relinquishment
            } else if let deposits = filterRelinquishments.deposit {
                resortName?.text = deposits.resort?.resortName
                lblHeading.text = Constant.MyClassConstants.relinquishment
            } else if let selectedBucket = Constant.MyClassConstants.selectedAvailabilityInventoryBucket, let pointsCost = selectedBucket.exchangePointsCost {
                switch Constant.exchangePointType {
                case ExchangePointType.CIGPOINTS:
                    lblHeading.text = ExchangePointType.CIGPOINTS.name.localized()
                    resortName?.text = "\(pointsCost)".localized()
                    resortDetailsButton.isHidden = true
                case ExchangePointType.CLUBPOINTS:
                    lblHeading.text = ExchangePointType.CLUBPOINTS.name.localized()
                    resortName?.text = "\(pointsCost)".localized()
                    resortDetailsButton.isHidden = true
                case ExchangePointType.UNKNOWN:
                    break
                }
            } else {
                resortName?.text = ""
                lblHeading.text = ""
            }
            resortDetailsButton.tag = indexPath.row
            resortImageView?.image = #imageLiteral(resourceName: "EXG_CO")
        }
        selectionStyle = .none
        
    }

}
