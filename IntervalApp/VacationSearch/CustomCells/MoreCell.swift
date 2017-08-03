//
//  MoreCell.swift
//  IntervalApp
//
//  Created by Chetu on 18/05/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class MoreCell: UICollectionViewCell {
    
    @IBOutlet weak var lblMonth: UILabel!
    
    @IBOutlet weak var lblStartYear: UILabel!
    
    @IBOutlet weak var lblEndYear: UILabel!
    
    
    func setDateForBucket(){
        let startDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.availableBucketArray[0].intervalStartDate!, format: Constant.MyClassConstants.dateFormat)
        let endDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.availableBucketArray[0].intervalEndDate!, format: Constant.MyClassConstants.dateFormat)
        
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
    
}
