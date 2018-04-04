//
//  CalendarViewController.swift
//  IntervalApp
//
//  Created by Chetu on 08/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import FSCalendar
import DarwinSDK

class CalendarViewController: UIViewController {
    
    //***** Outlets *****//
    @IBOutlet weak var fsCalendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    //***** class variables *****//
    let defaults = UserDefaults.standard
    var requestedDateWindow: String = ""
    var requestedController = ""
    var showNinetyDaysWindow = false
    
    var dateArray = [Date]()
    var datesToAllow = [Date]()

    var didSelectDate: ((Date?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuButton = UIBarButtonItem(image: UIImage(named: Constant.assetImageNames.backArrowNav), style: .plain, target: self, action: #selector(CalendarViewController.menuBackButtonPressed(_:)))
        menuButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = menuButton
    
        self.title = Constant.ControllerTitles.calendarViewController
        
        fsCalendar.scrollDirection = .vertical
        fsCalendar.appearance.caseOptions = [.headerUsesUpperCase, .weekdayUsesUpperCase]
        fsCalendar.delegate = self
        fsCalendar.dataSource = self
        
        //FIXME(FRANK): Remove this code
        //fsCalendar.formatter = Helper.createDateFormatter("yyyy/MM/dd")
        var calendar = Calendar.current
        if let timeZone = TimeZone(identifier: "UTC") {
            if var myCalendar = fsCalendar.calendar {
                myCalendar.timeZone = timeZone
            }
        } else {
            if var myCalendar = fsCalendar.calendar {
                myCalendar.timeZone = NSTimeZone.local
            }
        }

        if !datesToAllow.isEmpty {
            fsCalendar.select(Date())
        } else {
            if let date = Constant.MyClassConstants.relinquishmentFloatDetialSelectedDate {
                let dateWithoutTimeZone = createDateWithoutTimeZone(for: date)
                fsCalendar.select(dateWithoutTimeZone)
            } else {
                let dateWithoutTimeZone = createDateWithoutTimeZone(for: Constant.MyClassConstants.vacationSearchShowDate)
                fsCalendar.select(dateWithoutTimeZone)
            }
            fsCalendar.deselect(Date())
        }
    }

    private func createDateWithoutTimeZone(for date: Date) -> Date {
        let format = Date.intervalShortDateFormat
        let date = Constant.MyClassConstants.vacationSearchShowDate.formatDateAs(format)
        return fsCalendar.date(from: date, format: format)
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

    fileprivate func dateIsAllowed(_ date: Date) -> Bool {

        let foundMatch = datesToAllow.first {
            let calendar = CalendarHelper().createCalendar()
            let parsedDateFromAllowedDates = calendar.dateComponents([.day, .weekday, .month, .year], from: $0)
            let parsedDateFromCalendarDate = calendar.dateComponents([.day, .weekday, .month, .year], from: date)
            return parsedDateFromAllowedDates.month == parsedDateFromCalendarDate.month
                && parsedDateFromAllowedDates.day == parsedDateFromCalendarDate.day
                && parsedDateFromAllowedDates.year == parsedDateFromCalendarDate.year
        }

        return foundMatch != nil
    }
}

extension CalendarViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {

        let df = DateFormatter()
            df.dateFormat = "yyyy/MM/dd"
        let dateStr = df.string(from: date)
            df.timeZone = Helper.createTimeZone()
        let selectedDate = df.date(from: dateStr)
 
        if self.requestedController == Constant.MyClassConstants.relinquishment {
            
            Constant.MyClassConstants.relinquishmentAvalableToolSelectedDate = selectedDate
            _ = self.navigationController?.popViewController(animated: true)
        } else if self.requestedController == Constant.MyClassConstants.relinquishmentFlaotWeek {
            
            Constant.MyClassConstants.relinquishmentFloatDetialSelectedDate = selectedDate
            
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            
            defaults.set(selectedDate, forKey: Constant.MyClassConstants.selectedDate)
            Constant.MyClassConstants.vacationSearchShowDate = selectedDate.unsafelyUnwrapped
            
            if self.requestedDateWindow != "" && self.requestedDateWindow == Constant.MyClassConstants.start {
                
                Constant.MyClassConstants.alertWindowStartDate = selectedDate
            } else if self.requestedDateWindow != "" && self.requestedDateWindow == Constant.MyClassConstants.end {
                
                Constant.MyClassConstants.alertWindowEndDate = selectedDate
            }
            _ = self.navigationController?.popViewController(animated: true)
        }

        didSelectDate?(date)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date) -> Bool {

        if !datesToAllow.isEmpty {
            return dateIsAllowed(date)
        }

         if self.requestedController == Constant.MyClassConstants.relinquishment {
            return true
        } else {
            return true
        }
    }

}

extension CalendarViewController: FSCalendarDataSource {
    
    func minimumDate(for calendar: FSCalendar) -> Date {

        if let minimumDate = (datesToAllow.sorted { $0 < $1 }.first), !datesToAllow.isEmpty {
            return minimumDate
        }

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
    
    func maximumDate(for fsCalendar: FSCalendar) -> Date {

        if let maximumDate = (datesToAllow.sorted { $0 > $1 }.first), !datesToAllow.isEmpty {
            return maximumDate
        }

        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        
        if self.requestedController == Constant.MyClassConstants.relinquishmentFlaotWeek {
            
            guard let date = Constant.MyClassConstants.relinquishmentFloatDetialMaxDate else { return Date() }
            return date
            
        } else if showNinetyDaysWindow {
            if let alertWindowStartDate = Constant.MyClassConstants.alertWindowStartDate,
                let dateAfter90Days = calendar.date(byAdding: .month, value: 3, to: alertWindowStartDate) {
                return fsCalendar.date(withYear: (dateAfter90Days as NSDate).fs_year, month: (dateAfter90Days as NSDate).fs_month, day: (dateAfter90Days as NSDate).fs_day)
            } else {
                let date = Date()
                return fsCalendar.date(withYear: (date as NSDate).fs_year, month: (date as NSDate).fs_month, day: (date as NSDate).fs_day)
            }
        } else {
            
            if self.requestedDateWindow == Constant.MyClassConstants.start {
                if let dateAfterTwoYear = calendar.date(byAdding: .month, value: 24, to: Date()) {
                    return fsCalendar.date(withYear: (dateAfterTwoYear as NSDate).fs_year, month: (dateAfterTwoYear as NSDate).fs_month, day: (dateAfterTwoYear as NSDate).fs_day)
                } else {
                    let date = Date()
                    return fsCalendar.date(withYear: (date as NSDate).fs_year, month: (date as NSDate).fs_month, day: (date as NSDate).fs_day)
                }
            } else if self.requestedDateWindow == Constant.MyClassConstants.end {
                
                if let date = Constant.MyClassConstants.alertWindowEndDate {
                   
                    if let dateAfterTwoYear = calendar.date(byAdding: .month, value: 24, to: date) {
                    return fsCalendar.date(withYear: (dateAfterTwoYear as NSDate).fs_year, month: (dateAfterTwoYear as NSDate).fs_month, day: (dateAfterTwoYear as NSDate).fs_day)
                    } else {
                        let date = Date()
                        return fsCalendar.date(withYear: (date as NSDate).fs_year, month: (date as NSDate).fs_month, day: (date as NSDate).fs_day)
                    }
                } else {
                    
                    if let dateAfterTwoYear = calendar.date(byAdding: .month, value: 24, to: Date()) {
                    return fsCalendar.date(withYear: (dateAfterTwoYear as NSDate).fs_year, month: (dateAfterTwoYear as NSDate).fs_month, day: (dateAfterTwoYear as NSDate).fs_day)
                    } else {
                        let date = Date()
                        return fsCalendar.date(withYear: (date as NSDate).fs_year, month: (date as NSDate).fs_month, day: (date as NSDate).fs_day)
                    }
                }
            } else {
                if let dateAfterTwoYear = calendar.date(byAdding: .month, value: 24, to: Date()) {
                    return fsCalendar.date(withYear: (dateAfterTwoYear as NSDate).fs_year, month: (dateAfterTwoYear as NSDate).fs_month, day: (dateAfterTwoYear as NSDate).fs_day)
                } else {
                    let date = Date()
                    return fsCalendar.date(withYear: (date as NSDate).fs_year, month: (date as NSDate).fs_month, day: (date as NSDate).fs_day)
                }
            }
        }
    }

    func calendarCurrentPageDidChange(_ fsCalendar: FSCalendar) {
        NSLog("change page to \(fsCalendar.string(from: fsCalendar.currentPage))")
    }

}

extension CalendarViewController: FSCalendarDelegateAppearance {

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return datesToAllow.isEmpty ? nil : .clear
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return datesToAllow.isEmpty ? nil : .lightGray
    }
    
    public func calendar(_ fsCalendar: FSCalendar, appearance: FSCalendarAppearance, subtitleDefaultColorFor date: Date) -> UIColor? {

        if !datesToAllow.isEmpty {
            return dateIsAllowed(date) ? .blue : .lightGray
        }

        if self.requestedController == Constant.MyClassConstants.relinquishmentFlaotWeek {
            if Constant.MyClassConstants.floatDetailsCalendarDateArray.contains(date) {
                return UIColor.blue
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
                return UIColor.blue
            }
        }
        
    }

}
