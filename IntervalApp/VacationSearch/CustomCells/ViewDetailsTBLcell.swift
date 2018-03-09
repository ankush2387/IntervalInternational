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
            resortName?.text = Constant.MyClassConstants.selectedResort.resortName
        } else {
            lblHeading.text = Constant.MyClassConstants.relinquishment
            if let clubPoint = filterRelinquishments.clubPoints {
                resortName?.text = clubPoint.resort?.resortName
            } else if let openWeek = filterRelinquishments.openWeek {
                resortName?.text = openWeek.resort?.resortName
            } else if let deposits = filterRelinquishments.deposit {
                resortName?.text = deposits.resort?.resortName
            } else if filterRelinquishments.pointsProgram != nil {
                if Constant.MyClassConstants.isCIGAvailable {
                    resortDetailsButton.isHidden = true
                    lblHeading.text = "CIG Points"
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    if let pointsCost = Constant.MyClassConstants.selectedExchangePointsCost, let availablePoints = numberFormatter.string(from: pointsCost) {
                        resortName?.text = "\(availablePoints)".localized()
                    } else {
                        resortName?.text = "\(0)".localized()
                    }
                }
            }
            resortDetailsButton.tag = indexPath.row
            resortImageView?.image = #imageLiteral(resourceName: "EXG_CO")
        }
        selectionStyle = .none
        
    }

}
