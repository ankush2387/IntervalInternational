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
    
    static let identifier = "FloatSavedCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupDepositedCell(deposit: Deposit) {
        
        if let resortName = deposit.resort?.resortName {
           self.resortName.text = resortName.localized()
        }
        
        if let resortCode = deposit.resort?.resortCode {
            resortName.text?.append("-\(resortCode)".localized())
        }
        
        if let relinquishmentYear = deposit.relinquishmentYear {
            yearLabel.text = "\(relinquishmentYear)".localized()
        }
        
        if let unitSize = deposit.unit!.unitSize {
            bedroomSizeAndKitchenClient.text = "\(Helper.getBedroomNumbers(bedroomType: unitSize))".localized()
        }
        
        if let kitchenType = deposit.unit!.kitchenType {
            bedroomSizeAndKitchenClient.text?.append(", \(Helper.getKitchenEnums(kitchenType: kitchenType))".localized())
        }
        
        if let sleepCapacity = deposit.unit?.publicSleepCapacity {
            totalSleepAndPrivate.text = "Sleeps \(sleepCapacity) total".localized()
        }
        
        if let privateSleepCap = deposit.unit?.privateSleepCapacity {
            totalSleepAndPrivate.text?.append(", \(privateSleepCap) Private".localized())
        }
        
        if deposit.checkInDate != nil {
            
            let dateString = deposit.checkInDate
            let date = Helper.convertStringToDate(dateString: dateString!, format: Constant.destinationResortViewControllerCellIdentifiersAndHardCodedStrings.yyyymmddDateFormat)
            let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let myComponents = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: date)
            let day = myComponents.day!
            var month = ""
            if let monthNumber = myComponents.month {
                if day < 10 {
                    month = "\(Helper.getMonthnameFromInt(monthNumber: monthNumber)) 0\(day)"
                } else {
                    month = "\(Helper.getMonthnameFromInt(monthNumber: monthNumber)) \(day)"
                }
            }
            dayAndDateLabel.text = month.uppercased()
        } else {
            dayAndDateLabel.text = ""
        }
        
        if let weekNumber = deposit.weekNumber {
            totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: weekNumber))".localized()
        }
        if let expiredDate = deposit.expirationDate {
            let expirationDate = Helper.convertStringToDate(dateString: expiredDate, format: "yyyy-MM-dd")
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
        
        //hide promotions
        promLabel.isHidden = true
        promImgView.isHidden = true
        
    }
    
    func getDaysDiff(expiration: Date) -> Int {
        let cal = NSCalendar.current
        let returnDate = cal.dateComponents(Set<Calendar.Component>([.day]), from: Constant.MyClassConstants.todaysDate as Date, to: expiration )
        return returnDate.day!
    }
}
