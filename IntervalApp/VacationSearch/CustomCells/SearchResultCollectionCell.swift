//
//  SearchResultCollectionCell.swift
//  IntervalApp
//
//  Created by Chetu on 11/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

// Calendar Cell
class SearchResultCollectionCell: UICollectionViewCell {
    
    //***** Outlets *****//
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var daynameWithyearLabel: UILabel!
    @IBOutlet weak var monthYearLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setSingleDateItems(index: Int) {
        
        if let checkInDate = Constant.MyClassConstants.calendarDatesArray[index].checkInDate, let calendarDate = checkInDate.dateFromShortFormat() {
            let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
            
            let startComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: calendarDate)
            let year = "\(startComponents.year ?? 0)"
            let monthName = "\(Helper.getMonthnameFromInt(monthNumber: startComponents.month ?? 0))"
            
            //FIXME(FRANK): What is this?
            let day = startComponents.day ?? 0
            if day < 10 {
                dateLabel.text = "0\(day)".localizedUppercase
            } else {
                dateLabel.text = "\(day)".localizedUppercase
            }
            
            dateLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 25)
            daynameWithyearLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: startComponents.weekday ?? 0))".localized()
            let str: String = daynameWithyearLabel.text ?? ""
            let index1 = str.index(str.endIndex, offsetBy: -(str.count - 3))
            let substring1 = str.substring(to: index1)
            daynameWithyearLabel.text = substring1.uppercased()
            monthYearLabel.text = "\(monthName) \(year)".localizedUppercase
            monthYearLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 7)
        }
    }

}
