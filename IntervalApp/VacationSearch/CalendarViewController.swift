//
//  CalendarViewController.swift
//  IntervalApp
//
//  Created by Chetu on 08/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    //***** class variables *****//
    let defaults = UserDefaults.standard
    var requestedDateWindow: String = ""
    var requestedController = ""
    
    var dateArray = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(CalendarViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
    
        self.title = Constant.ControllerTitles.calendarViewController
        calendar.scrollDirection = .vertical
        calendar.appearance.caseOptions = [.headerUsesUpperCase, .weekdayUsesUpperCase]
        calendar.delegate = self
          calendar.dataSource = self
        if let date = Constant.MyClassConstants.relinquishmentFloatDetialSelectedDate {
            calendar.select(date)
        } else {
             calendar.select(Constant.MyClassConstants.vacationSearchShowDate)
        }
        calendar.deselect(Date())
    }
    //***** navigation back button action *****//
    func menuBackButtonPressed(_ sender: UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CalendarViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        
        if self.requestedController == Constant.MyClassConstants.relinquishment {
            
            Constant.MyClassConstants.relinquishmentAvalableToolSelectedDate = date
            _ = self.navigationController?.popViewController(animated: true)
        } else if self.requestedController == Constant.MyClassConstants.relinquishmentFlaotWeek {
            
            Constant.MyClassConstants.relinquishmentFloatDetialSelectedDate = date
            
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            
            defaults.set(date, forKey: Constant.MyClassConstants.selectedDate)
            Constant.MyClassConstants.vacationSearchShowDate = date
            
            if self.requestedDateWindow != "" && self.requestedDateWindow == Constant.MyClassConstants.start {
                
                Constant.MyClassConstants.alertWindowStartDate = date
            } else if self.requestedDateWindow != "" && self.requestedDateWindow == Constant.MyClassConstants.end {
                
                Constant.MyClassConstants.alertWindowEndDate = date
            }
            _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date) -> Bool {
        
         if self.requestedController == Constant.MyClassConstants.relinquishment {
            return true
        } else {
            return true
        }
    }
}

extension CalendarViewController: FSCalendarDataSource {
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        
        if self.requestedController == Constant.MyClassConstants.relinquishmentFlaotWeek {
            guard let date = Constant.MyClassConstants.relinquishmentFloatDetialMinDate else { return Date() }
            return date
            
        } else {
            
            if self.requestedDateWindow == Constant.MyClassConstants.start {
                let date = Date()
                return calendar.date(withYear: (date as NSDate).fs_year, month: (date as NSDate).fs_month, day: (date as NSDate).fs_day)
            } else if self.requestedDateWindow == Constant.MyClassConstants.end {
                
                if let date = Constant.MyClassConstants.alertWindowStartDate {
                     return calendar.date(withYear: (date as NSDate).fs_year, month: (date as NSDate).fs_month, day: (date as NSDate).fs_day)
                } else {
                    return calendar.date(withYear: (Date() as NSDate).fs_year, month: (Date() as NSDate).fs_month, day: (Date() as NSDate).fs_day)
            }
            } else {
                 return calendar.date(withYear: (Date() as NSDate).fs_year, month: (Date() as NSDate).fs_month, day: (Date() as NSDate).fs_day)
            }
    }
}
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        
        if self.requestedController == Constant.MyClassConstants.relinquishmentFlaotWeek {
            
            guard let date = Constant.MyClassConstants.relinquishmentFloatDetialMaxDate else { return Date() }
            return date
            
        } else {
            
            if self.requestedDateWindow == Constant.MyClassConstants.start {
                if let dateAfterTwoYear = Calendar.current.date(byAdding: .month, value: 24, to: Date()) {
                    return calendar.date(withYear: (dateAfterTwoYear as NSDate).fs_year, month: (dateAfterTwoYear as NSDate).fs_month, day: (dateAfterTwoYear as NSDate).fs_day)
                } else {
                    let date = Date()
                    return calendar.date(withYear: (date as NSDate).fs_year, month: (date as NSDate).fs_month, day: (date as NSDate).fs_day)
                }
            } else if self.requestedDateWindow == Constant.MyClassConstants.end {
                
                if let date = Constant.MyClassConstants.alertWindowEndDate {
                   
                    if let dateAfterTwoYear = Calendar.current.date(byAdding: .month, value: 24, to: date) {
                    return calendar.date(withYear: (dateAfterTwoYear as NSDate).fs_year, month: (dateAfterTwoYear as NSDate).fs_month, day: (dateAfterTwoYear as NSDate).fs_day)
                    } else {
                        let date = Date()
                        return calendar.date(withYear: (date as NSDate).fs_year, month: (date as NSDate).fs_month, day: (date as NSDate).fs_day)
                    }
                } else {
                    
                    if let dateAfterTwoYear = Calendar.current.date(byAdding: .month, value: 24, to: Date()) {
                    return calendar.date(withYear: (dateAfterTwoYear as NSDate).fs_year, month: (dateAfterTwoYear as NSDate).fs_month, day: (dateAfterTwoYear as NSDate).fs_day)
                    } else {
                        let date = Date()
                        return calendar.date(withYear: (date as NSDate).fs_year, month: (date as NSDate).fs_month, day: (date as NSDate).fs_day)
                    }
                }
            } else {
                if let dateAfterTwoYear = Calendar.current.date(byAdding: .month, value: 24, to: Date()) {
                    return calendar.date(withYear: (dateAfterTwoYear as NSDate).fs_year, month: (dateAfterTwoYear as NSDate).fs_month, day: (dateAfterTwoYear as NSDate).fs_day)
                } else {
                    let date = Date()
                    return calendar.date(withYear: (date as NSDate).fs_year, month: (date as NSDate).fs_month, day: (date as NSDate).fs_day)
                }
        }
    }
}
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        NSLog("change page to \(calendar.string(from: calendar.currentPage))")
    }

}

extension CalendarViewController: FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
         if self.requestedController == Constant.MyClassConstants.relinquishmentFlaotWeek {
            if Constant.MyClassConstants.floatDetailsCalendarDateArray.contains(date) {
                return UIColor.darkText
            } else {
                return UIColor.lightGray
            }
         } else {
            var startDT: Date
            if self.requestedDateWindow == Constant.MyClassConstants.end {
                startDT = Constant.MyClassConstants.alertWindowStartDate ?? Date()
            } else {
                startDT = Date()
            }
            if date .isLessThanDate(Date()) {
                return UIColor.lightGray
            } else if date .isLessThanDate(startDT) {
                 return UIColor.lightGray
            } else {
                return UIColor.darkText
            }
        }
    }
    
    public func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleDefaultColorFor date: Date) -> UIColor? {
        
        if self.requestedController == Constant.MyClassConstants.relinquishmentFlaotWeek {
            if Constant.MyClassConstants.floatDetailsCalendarDateArray.contains(date) {
                return UIColor.darkText
            } else {
                return UIColor.lightGray
            }
        } else {
            var startDT: Date
            if self.requestedDateWindow == Constant.MyClassConstants.end {
                startDT = Constant.MyClassConstants.alertWindowStartDate ?? Date()
            } else {
                startDT = Date()
            }
            if date .isLessThanDate(Date()) {
                return UIColor.lightGray
            } else if date .isLessThanDate(startDT) {
                return UIColor.lightGray
            } else {
                return UIColor.darkText
            }
        }
        
    }

}
