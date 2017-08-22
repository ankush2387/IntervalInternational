//
//  UpComingTripCell.swift
//  IntervalApp
//
//  Created by Chetu on 09/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class UpComingTripCell: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var resortImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerStatusLabel: UILabel!
    @IBOutlet weak var resortCodeLabel: UILabel!
    @IBOutlet weak var resortLocationLabel: UILabel!
    @IBOutlet weak var resortNameLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tripDateLabel: UILabel!
    @IBOutlet weak var footerViewDetailedButton: IUIKButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var resortType: UILabel!
    
    @IBOutlet weak var resortNameBaseView: UIView!
    
    @IBOutlet weak var transactionType: UILabel!
    @IBOutlet weak var sleepsTotalOrPrivate: UILabel!
    @IBOutlet weak var bedRoomKitechenType: UILabel!
    @IBOutlet weak var collectionVwTripDetails: UICollectionView!
    
    @IBOutlet weak var inDateHeading: UILabel!
    @IBOutlet weak var outDateHeading: UILabel!
    @IBOutlet weak var checkInDateLabel: UILabel!
    @IBOutlet weak var checkOutDateLabel: UILabel!
    @IBOutlet weak var checkInMonthYearLabel: UILabel!
    @IBOutlet weak var checkOutMonthYearLabel: UILabel!
    @IBOutlet weak var showMapDetailButton: UIButton!
    @IBOutlet weak var showWeatherDetailButton: UIButton!
    @IBOutlet weak var checkinDayLabel: UILabel!
    @IBOutlet weak var checkoutDayLabel: UILabel!
    
    @IBOutlet weak var resortFixedWeekLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //***** Initialization code *****//
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        //***** Configure the view for the selected state ******//
    }

}
