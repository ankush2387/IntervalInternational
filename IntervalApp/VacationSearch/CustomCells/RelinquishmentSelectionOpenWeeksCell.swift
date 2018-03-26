//
//  RelinquishmentSelectionOpenWeeksCell.swift
//  IntervalApp
//
//  Created by Chetu on 10/01/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class RelinquishmentSelectionOpenWeeksCell: UITableViewCell {
    
    //IBOutlets
    @IBOutlet weak var dayAndDateLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var totalWeekLabel: UILabel!
    
    @IBOutlet weak var resortDetailsView: UIView!
    @IBOutlet weak var totalSleepAndPrivate: UILabel!
    @IBOutlet weak var bedroomSizeAndKitchenClient: UILabel!
    @IBOutlet weak var resortName: UILabel!
    @IBOutlet weak var dayandDateLabel: UIView!
    
    @IBOutlet weak var addButton: IUIKButton?
    @IBOutlet weak var savedView: UILabel!
 
    @IBOutlet weak var promLabel: UILabel!
    @IBOutlet weak var promImgView: UIImageView!
    @IBOutlet weak var expirationMessageLabel: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var checkBox: IUIKCheckbox!
    
    @IBOutlet weak var requestTypeLbl: UILabel!
    @IBOutlet weak var expiresDateLbl: UILabel!
    
    static let identifier = "FloatSavedCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupOpenWeekCell(openWeek: OpenWeek) {
        
        resortName.text = openWeek.resort?.resortName ?? ""
        yearLabel.text = "\(String(describing: openWeek.relinquishmentYear ?? 0))".localized()
        totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: openWeek.weekNumber ?? ""))".localized()
        
        bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType: openWeek.unit?.unitSize ?? ""))), \(Helper.getKitchenEnums(kitchenType: openWeek.unit?.kitchenType ?? "")), \(openWeek.unit?.unitNumber ?? "")".localized()

        if let sleepCapacity = openWeek.unit?.publicSleepCapacity {
            totalSleepAndPrivate.text = "Sleeps \(sleepCapacity) Total".localized()
        }
        
        if let privateSleepCap = openWeek.unit?.privateSleepCapacity {
            totalSleepAndPrivate.text?.append(", \(privateSleepCap) Private".localized())
        }
        
        if let checkInDate = openWeek.checkInDate, let formattedCheckInDate = checkInDate.dateFromString(for: Constant.MyClassConstants.dateFormat) {
            let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
            let myComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: formattedCheckInDate)
            let day = myComponents.day ?? 0
            var month = ""
            if day < 10 {
                month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month ?? 0)) 0\(day)"
            } else {
                month = "\(Helper.getMonthnameFromInt(monthNumber: myComponents.month ?? 0)) \(day)"
            }
            dayAndDateLabel.text = month.uppercased()
        } else {
             dayAndDateLabel.text = nil
        }
  
        //display Promotion
        if let promotion = openWeek.promotion {
            promLabel.text = promotion.offerName
            promImgView.image = UIImage(named: "PromoImage")
        } else {
            promLabel.text = ""
            promImgView.image = nil
        }
    }
    
    func setupDepositedCell(deposit: Deposit) {
        
        if let strResortName = deposit.resort?.resortName {
           resortName.text = strResortName.localized()
        }
        
        if let resortCode = deposit.resort?.resortCode {
            resortName.text?.append("-\(resortCode)".localized())
        }
        
        if let type = deposit.requestType {
            if type == Constant.MyClassConstants.depositType {
                requestTypeLbl.text = Constant.MyClassConstants.lateDeposit
            } else {
                requestTypeLbl.text = nil
            }
            
        }
        
        if let relinquishmentYear = deposit.relinquishmentYear {
            yearLabel.text = "\(relinquishmentYear)".localized()
        }

        if let unitSize = deposit.unit?.unitSize, let kitchenType = deposit.unit?.kitchenType, let unitNumber = deposit.unit?.unitNumber {
            let unitSizeString = "\(Helper.getBedroomNumbers(bedroomType: unitSize)), \(Helper.getKitchenEnums(kitchenType: kitchenType)), \(unitNumber)"
            let attributedString = NSMutableAttributedString(string:unitSizeString)
            bedroomSizeAndKitchenClient.attributedText = attributedString
        }
        
        if let sleepCapacity = deposit.unit?.publicSleepCapacity {
            totalSleepAndPrivate.text = "Sleeps \(sleepCapacity) Total".localized()
        }
        
        if let privateSleepCap = deposit.unit?.privateSleepCapacity {
            totalSleepAndPrivate.text?.append(", \(privateSleepCap) Private".localized())
        }
        
        if deposit.checkInDate != nil {
            var dateString = ""
            if let dateStr = deposit.checkInDate {
                dateString = dateStr
            }
            if let date = dateString.dateFromShortFormat() {
                let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
                let myComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: date)
                let day = myComponents.day ?? 0
                var month = ""
                if let monthNumber = myComponents.month {
                    if day < 10 {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: monthNumber)) 0\(day)"
                    } else {
                        month = "\(Helper.getMonthnameFromInt(monthNumber: monthNumber)) \(day)"
                    }
                    dayAndDateLabel.text = month.uppercased()
                }
            }
            
        } else {
            dayAndDateLabel.text = ""
        }
        
        if let weekNumber = deposit.weekNumber {
            totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: weekNumber))".localized()
        }
        if let expiredDate = deposit.expirationDate {
            if let expirationDate = expiredDate.dateFromShortFormat() {
                let diff = getDaysDiff(expiration: expirationDate)
                
                if diff > 0 {
                    expirationMessageLabel.text = "Expires in \(diff) days.".localized()
                    addButton?.isHidden = false
                } else if diff == 0 {
                    expirationMessageLabel.text = "Expiring today".localized()
                    addButton?.isHidden = false
                } else {
                    expirationMessageLabel.text = "Expired on \(expiredDate)".localized()
                    addButton?.isHidden = true
                }
            }
        }
        
        //display Promotion
        if let promotion = deposit.promotion {
            promLabel.text = promotion.offerContentFragment
            promImgView.image = UIImage(named: "PromoImage")
        } else {
            promLabel.text = ""
            promImgView.image = nil
        }
        
    }
    
    func getDaysDiff(expiration: Date) -> Int {
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        let returnDate = calendar.dateComponents(Set<Calendar.Component>([.day]), from: Constant.MyClassConstants.todaysDate as Date, to: expiration )
        return returnDate.day ?? 0
    }
}
