//
//  AvailablePointCell.swift
//  IntervalApp
//
//  Created by Chetu on 14/01/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class AvailablePointCell: UITableViewCell {
    
    //Outlets
    
    @IBOutlet weak var availablePointValueLabel: UILabel!
    @IBOutlet weak var pointsInfoLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var checkBOx: IUIKCheckbox!
    @IBOutlet weak var infoButton: UIButton!
    
    func setupClubPointsCell(clubPoints: ClubPoints) {
        if let resort = clubPoints.resort, let resortName = resort.resortName {
            pointsInfoLabel.text = resortName
        } else {
            pointsInfoLabel.text = nil
        }
        
        if let points = clubPoints.pointsSpent {
            availablePointValueLabel.text = String(points)
        } else {
            availablePointValueLabel.text = nil
        }
    }

}
