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
    
    var dateArray = [Date]()
    var datesToAllow = [Date]()

    var calendarContext: CalendarContext?
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
        self.navigationController?.popViewController(animated: true)
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
 
        didSelectDate?(selectedDate)
        self.navigationController?.popViewController(animated: true)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date) -> Bool {

        if !datesToAllow.isEmpty {
            return dateIsAllowed(date)
        }
        return true
    }

}

extension CalendarViewController: FSCalendarDataSource {
    
    func getCalendar(for calendar: FSCalendar, andDate date: Date) -> Date {
        var cal = Calendar.current
        guard let timeZone = TimeZone(identifier: "UTC") else { return date }
        cal.timeZone = timeZone
        let components = cal.dateComponents([.day, .month, .year], from: date)
        let yearOpt = components.year
        let monthOpt = components.month
        let dayOpt = components.day
        if let year = yearOpt, let month = monthOpt, let day = dayOpt {
            return calendar.date(withYear: year, month: month, day: day)
        }
        return date
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {

        if let minimumDate = (datesToAllow.sorted { $0 < $1 }.first), !datesToAllow.isEmpty {
            return minimumDate
        }

        if let context = calendarContext {
            switch context {
            case .additionalInformationFloatWeek:
                guard let date = Constant.MyClassConstants.relinquishmentFloatDetialMinDate else { return Date() }
                return date
            case .alertEndDate:
                return getCalendar(for: calendar, andDate: Constant.MyClassConstants.alertWindowStartDate ?? Date())
            default:
                return getCalendar(for: calendar, andDate: Date())
            }
        } else {
            return getCalendar(for: calendar, andDate: Date())
        }
        
    }
    
    func maximumDate(for fsCalendar: FSCalendar) -> Date {

        if let maximumDate = (datesToAllow.sorted { $0 > $1 }.first), !datesToAllow.isEmpty {
            return maximumDate
        }

        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        
        if let context = calendarContext {
            switch context {
            case .additionalInformationFloatWeek:
                guard let date = Constant.MyClassConstants.relinquishmentFloatDetialMaxDate else { return Date() }
                return date
            case .alertEndDate:
                let date = Constant.MyClassConstants.alertWindowEndDate ?? Date()
                let dateAfterTwoYear = calendar.date(byAdding: .month, value: 24, to: date) ?? Date()
                return getCalendar(for: fsCalendar, andDate: dateAfterTwoYear)
            default:
                let dateAfterTwoYear = calendar.date(byAdding: .month, value: 24, to: Date()) ?? Date()
                return getCalendar(for: fsCalendar, andDate: dateAfterTwoYear)
                
            }
        } else {
            let dateAfterTwoYear = calendar.date(byAdding: .month, value: 24, to: Date()) ?? Date()
            return getCalendar(for: fsCalendar, andDate: dateAfterTwoYear)
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

        var startDT: Date = Date()
        if let context = calendarContext {
            switch context {
            case .additionalInformationFloatWeek:
                if Constant.MyClassConstants.floatDetailsCalendarDateArray.contains(date) {
                    return UIColor.blue
                } else {
                    return UIColor.lightGray
                }
            case .alertEndDate:
                startDT = Constant.MyClassConstants.alertWindowStartDate ?? Date()
            default:
                break
            }
        }
        return date.isLessThanDate(Date()) || date.isLessThanDate(startDT) ? .lightGray : .blue
        
    }

}
