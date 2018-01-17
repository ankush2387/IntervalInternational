//
//  UpComingTripCell.swift
//  IntervalApp
//
//  Created by Chetu on 09/02/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK
import Foundation

class UpComingTripCell: UITableViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var resortImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tripTypeLabel: UILabel!
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
    
    @IBOutlet weak var searchVacationButton: UIButton!
    @IBOutlet weak var checkInDateView: UIView!
    @IBOutlet weak var checkOutDateView: UIView!
    
    func setConfirmationAndType(with confirmationNumber: String, tripType: String) {
        headerLabel.text = "Confirmation # \(confirmationNumber)"
        tripTypeLabel.text = tripType.uppercased()
    }
    
    func setGuestDetails(with guest: Guest) {
        if let firstName = guest.firstName, let lastName = guest.lastName {
            resortNameLabel.text = "\(firstName) \(lastName)"
        }
    }
    
    func setTripInformation(with cruiseDetails: Cruise) {
        resortNameLabel.text = cruiseDetails.shipName
        resortLocationLabel.text = cruiseDetails.tripName
    }
    
    func setTripInformation(with resortDetails: Resort) {
        
    }
    
    func setDateDetails(with checkInDate: String, checkOutDate: String) {
        
        checkInDateView.layer.borderColor = UIColor.lightGray.cgColor
        checkOutDateView.layer.borderColor = UIColor.lightGray.cgColor
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let checkInDate = Helper.convertStringToDate(dateString: checkInDate, format: Constant.MyClassConstants.dateFormat)
        let checkOutDate = Helper.convertStringToDate(dateString: checkOutDate, format: Constant.MyClassConstants.dateFormat)
        
        let checkIndateComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: checkInDate)
        if let day = checkIndateComponents.day, let month = checkIndateComponents.month, let weekDay = checkIndateComponents.weekday, let  year = checkIndateComponents.year {
            
            checkInDateLabel.text = "\(String(format: "%02d", arguments: [day]))"
            checkinDayLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: weekDay))"
            checkInMonthYearLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month)) \(year)"
        }
        
        let checkOutdateComponents = (calendar as NSCalendar).components([.day, .weekday, .month, .year], from: checkOutDate)
        
        if let day = checkOutdateComponents.day, let month = checkOutdateComponents.month, let weekDay = checkOutdateComponents.weekday, let year = checkOutdateComponents.year {
            checkOutDateLabel.text = "\(String(format: "%02d", arguments: [day]))"
            checkoutDayLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: weekDay))"
            let formatedCheckOutDate = "\(Helper.getMonthnameFromInt(monthNumber: month)). \(year)"
            checkOutMonthYearLabel.text = formatedCheckOutDate
        }
    }
    
    func setDepositInformation(with depositDetails: Deposit) {
        
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        if let checkInDate = depositDetails.checkInDate {
            let checkInDate = Helper.convertStringToDate(dateString: checkInDate, format: Constant.MyClassConstants.dateFormat)
            
            let dateComponents = myCalendar.dateComponents([.day, .weekday, .month, .year], from: checkInDate)
            if let day = dateComponents.day, let month = dateComponents.month {
                checkInDateLabel.text = "\(Helper.getMonthnameFromInt(monthNumber: month)) \(String(format: "%02d", arguments: [day]))"
            }
            
            if let relinquishmentYr = depositDetails.relinquishmentYear {
                checkInMonthYearLabel.text = "\(relinquishmentYr)"
            }
            
            if let weekNumber = depositDetails.weekNumber {
                resortFixedWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: weekNumber))"
            }
            
            if let unitSize = depositDetails.unit?.unitSize, let kitchenType = depositDetails.unit?.kitchenType {
                bedRoomKitechenType.text =  "\(Helper.getBedroomNumbers(bedroomType: unitSize)) \(Helper.getKitchenEnums(kitchenType: kitchenType))"
            }
            
            if let publicSleeps = depositDetails.unit?.publicSleepCapacity, let privateSleeps = depositDetails.unit?.privateSleepCapacity {
                sleepsTotalOrPrivate.text = "Sleeps \(publicSleeps) total, \(privateSleeps) Private"
            }
        }
    }

}
