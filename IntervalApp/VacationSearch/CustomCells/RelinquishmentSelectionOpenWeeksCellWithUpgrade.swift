//
//  RelinquishmentSelectionOpenWeeksCell1.swift
//  IntervalApp
//
//  Created by Chetu on 06/07/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class RelinquishmentSelectionOpenWeeksCellWithUpgrade: UITableViewCell {

    //IBOutlets
    @IBOutlet weak var dayAndDateLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var totalWeekLabel: UILabel!
    @IBOutlet weak var totalSleepAndPrivate: UILabel!
    @IBOutlet weak var bedroomSizeAndKitchenClient: UILabel!
    @IBOutlet weak var resortName: UILabel!
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var lblFees: UILabel!
    @IBOutlet weak var checkBox: IUIKCheckbox!

    @IBOutlet weak var lblUpgrade: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //FIXME(Frank): Where is the Promotion?
    // OpenWeek can have a Promotion an UnitSize Upgrade Fee at the same time
    func setupOpenWeekCell(openWeek: OpenWeek) {
        
        resortName.text = openWeek.resort?.resortName ?? "".localized()
        yearLabel.text = "\(String(describing: openWeek.relinquishmentYear ?? 0))".localized()
        totalWeekLabel.text = "Week \(Constant.getWeekNumber(weekType: openWeek.weekNumber ?? ""))".localized()
        bedroomSizeAndKitchenClient.text = "\(String(describing: Helper.getBedroomNumbers(bedroomType: openWeek.unit?.unitSize ?? ""))), \(Helper.getKitchenEnums(kitchenType: openWeek.unit?.kitchenType ?? ""))".localized()
        
        if let unit = openWeek.unit {
            totalSleepAndPrivate.text = "Sleeps \(unit.publicSleepCapacity) total, \(unit.privateSleepCapacity) Private".localized()
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
    }

}
