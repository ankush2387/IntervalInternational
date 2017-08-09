//
//  MoreCell.swift
//  IntervalApp
//
//  Created by Chetu on 18/05/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class MoreCell: UICollectionViewCell {
    
    @IBOutlet weak var lblMonth: UILabel!
    
    @IBOutlet weak var lblStartYear: UILabel!
    
    @IBOutlet weak var lblEndYear: UILabel!
    
    
    func setDateForBucket(index: Int, selectedIndex: Int, color: String){
        
        setUpCell(index: index, collectionViewSelectedIndex: selectedIndex, dateSelectionColor: color)

        
        let startDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.calendarDatesArray[index].intervalStartDate!, format: Constant.MyClassConstants.dateFormat)
        let endDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.calendarDatesArray[index].intervalEndDate!, format: Constant.MyClassConstants.dateFormat)
        
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let startComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: startDate)
        let endComponents = (myCalendar as NSCalendar).components([.day,.weekday,.month,.year], from: endDate)
        let startYear = String(describing: startComponents.year!)
        let endYear = String(describing: endComponents.year!)
        
        let monthStartName = "\(Helper.getMonthnameFromInt(monthNumber: startComponents.month!))"
        let monthEndName = "\(Helper.getMonthnameFromInt(monthNumber: endComponents.month!))"
        lblMonth.text = "\(monthStartName) - \(monthEndName)".uppercased()
        lblStartYear.text = "\(startYear)"
        lblEndYear.text = "\(endYear)"
        
    }
    
    func setUpCell(index:Int, collectionViewSelectedIndex: Int, dateSelectionColor:String){
        self.layer.cornerRadius = 7
        self.layer.borderWidth = 2
        self.layer.borderColor = IUIKColorPalette.titleBackdrop.color.cgColor
        self.layer.masksToBounds = true
        
        if (Constant.MyClassConstants.calendarDatesArray[index].isIntervalAvailable)! {
            self.isUserInteractionEnabled = true
        }else {
            self.isUserInteractionEnabled = false
        }
        
        if(index == collectionViewSelectedIndex) {
            if(dateSelectionColor == "Green"){
                self.backgroundColor = IUIKColorPalette.secondary1.color
            }else{
                self.backgroundColor = IUIKColorPalette.primary1.color
            }
            self.lblMonth.textColor = UIColor.white
            self.lblStartYear.textColor = UIColor.white
            self.lblEndYear.textColor = UIColor.white
        }
        else {
            self.backgroundColor = UIColor.white
            self.lblMonth.textColor = IUIKColorPalette.primary1.color
            self.lblStartYear.textColor = IUIKColorPalette.primary1.color
            self.lblEndYear.textColor = IUIKColorPalette.primary1.color
        }
    }
    
}
