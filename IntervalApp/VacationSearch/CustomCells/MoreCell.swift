//
//  MoreCell.swift
//  IntervalApp
//
//  Created by Chetu on 18/05/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class MoreCell: UICollectionViewCell {
    
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblStartYear: UILabel!
    @IBOutlet weak var lblEndYear: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    
    func setDateForBucket(index: Int, selectedIndex: Int, color: String) {
        
        setUpCell(index: index, collectionViewSelectedIndex: selectedIndex, dateSelectionColor: color)
        
        let startDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.calendarDatesArray[index].intervalStartDate ?? "", format: Constant.MyClassConstants.dateFormat)
        let endDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.calendarDatesArray[index].intervalEndDate ?? "", format: Constant.MyClassConstants.dateFormat)
        
        intervalPrint(startDate, endDate)
        
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        let startComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: startDate)
        let endComponents = calendar.dateComponents([.day, .weekday, .month, .year], from: endDate)
        let startYear =  "\(startComponents.year ?? 0)"
        let endYear = "\(endComponents.year ?? 0)"
        
        let monthStartName = "\(Helper.getMonthnameFromInt(monthNumber: startComponents.month ?? 0))"
        let monthEndName = "\(Helper.getMonthnameFromInt(monthNumber: endComponents.month ?? 0))"
        lblMonth.text = "\(monthStartName) - \(monthEndName)".localizedUppercase
        lblStartYear.text = "\(startYear)".localized()
        lblEndYear.text = "\(endYear)".localized()
        
    }
    
    func setUpCell(index: Int, collectionViewSelectedIndex: Int, dateSelectionColor: String) {
        self.layer.cornerRadius = 7
        self.layer.borderWidth = 2
        self.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
        self.layer.masksToBounds = true
    }
    
}
