//
//  SearchResultCollectionCell.swift
//  IntervalApp
//
//  Created by Chetu on 11/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

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
        
        let calendarDate = Helper.convertStringToDate(dateString: Constant.MyClassConstants.calendarDatesArray[index].checkInDate!, format: Constant.MyClassConstants.dateFormat)
        
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let startComponents = (myCalendar as NSCalendar).components([.day, .weekday, .month, .year], from: calendarDate)
        let year = String(describing: startComponents.year!)
        let monthName = "\(Helper.getMonthnameFromInt(monthNumber: startComponents.month!))"
        dateLabel.text = "\(startComponents.day!)".uppercased()
        if(dateLabel.text?.characters.count == 1) {
            dateLabel.text = "0\(startComponents.day!)".uppercased()
        }
        dateLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 25)
        daynameWithyearLabel.text = "\(Helper.getWeekdayFromInt(weekDayNumber: startComponents.weekday!))"
        let str: String = daynameWithyearLabel.text!
        let index1 = str.index(str.endIndex, offsetBy: -(str.characters.count - 3))
        let substring1 = str.substring(to: index1)
        daynameWithyearLabel.text = substring1.uppercased()
        
        monthYearLabel.text = "\(monthName) \(year)".uppercased()
        monthYearLabel.font = UIFont(name: Constant.fontName.helveticaNeue, size: 7)
    }

}
