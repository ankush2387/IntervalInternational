//
//  CalendarViewController.swift
//  IntervalApp
//
//  Created by Chetu on 08/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController,FSCalendarDataSource, FSCalendarDelegate {
    
    //***** Outlets *****//
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    //***** class variables *****//
    let defaults = UserDefaults.standard
    var requestedDateWindow:String = ""
    var requestedController = ""
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let barAppearace = UIBarButtonItem.appearance()
        barAppearace.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), for:UIBarMetrics.default)
        self.title = Constant.ControllerTitles.calendarViewController
        calendar.scrollDirection = .vertical
        calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesUpperCase]
        calendar.delegate = self
        calendar.select(Constant.MyClassConstants.vacationSearchShowDate as Date)
        calendar.deselect(Date())
    }
    //***** navigation back button action *****//
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        
        if(self.requestedDateWindow == Constant.MyClassConstants.start) {
            
            if(Constant.MyClassConstants.alertWindowStartDate != nil) {
                let date = Date()
                return calendar.date(withYear: (date as NSDate).fs_year, month: (date as NSDate).fs_month, day: (date as NSDate).fs_day)
            }
            else {
                return calendar.date(withYear: (Date() as NSDate).fs_year, month: (Date() as NSDate).fs_month, day: (Date() as NSDate).fs_day)
            }
        }
        else if(self.requestedDateWindow == Constant.MyClassConstants.end) {
            
            let date = Constant.MyClassConstants.alertWindowStartDate as NSDate!
            return calendar.date(withYear: date!.fs_year, month: date!.fs_month, day: date!.fs_day)
        }
        else {
            return calendar.date(withYear: (Date() as NSDate).fs_year, month: (Date() as NSDate).fs_month, day: (Date() as NSDate).fs_day)
        }
        
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        
        if(self.requestedDateWindow == Constant.MyClassConstants.start) {
            
            if(Constant.MyClassConstants.alertWindowStartDate != nil) {
                
                let dateAfterTwoYear =  (Calendar.current as NSCalendar).date(byAdding: .month, value: 24, to:Constant.MyClassConstants.alertWindowStartDate as Date, options: [])!
                return calendar.date(withYear: (dateAfterTwoYear as NSDate).fs_year, month: (dateAfterTwoYear as NSDate).fs_month, day: (dateAfterTwoYear as NSDate).fs_day)
            }
            else {
                
                let dateAfterTwoYear =  (Calendar.current as NSCalendar).date(byAdding: .month, value: 24, to: Date(), options: [])!
                return calendar.date(withYear: (dateAfterTwoYear as NSDate).fs_year, month: (dateAfterTwoYear as NSDate).fs_month, day: (dateAfterTwoYear as NSDate).fs_day)
            }
        }
        else if(self.requestedDateWindow == Constant.MyClassConstants.end){
            
            if(Constant.MyClassConstants.alertWindowEndDate == nil) {
                
                let dateAfterTwoYear =  (Calendar.current as NSCalendar).date(byAdding: .month, value: 24, to: Constant.MyClassConstants.alertWindowStartDate as Date, options: [])!
                return calendar.date(withYear: (dateAfterTwoYear as NSDate).fs_year, month: (dateAfterTwoYear as NSDate).fs_month, day: (dateAfterTwoYear as NSDate).fs_day)
            }
            else {
                
                let dateAfterTwoYear =  (Calendar.current as NSCalendar).date(byAdding: .month, value: 24, to: Constant.MyClassConstants.alertWindowEndDate as Date, options: [])!
                return calendar.date(withYear: (dateAfterTwoYear as NSDate).fs_year, month: (dateAfterTwoYear as NSDate).fs_month, day: (dateAfterTwoYear as NSDate).fs_day)
            }
        }
        else {
            
            let dateAfterTwoYear =  (Calendar.current as NSCalendar).date(byAdding: .month, value: 24, to: Date(), options: [])!
            return calendar.date(withYear: (dateAfterTwoYear as NSDate).fs_year, month: (dateAfterTwoYear as NSDate).fs_month, day: (dateAfterTwoYear as NSDate).fs_day)
        }
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        NSLog("change page to \(calendar.string(from: calendar.currentPage))")
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        
        if(self.requestedController == Constant.MyClassConstants.relinquishment) {
            
            Constant.MyClassConstants.relinquishmentAvalableToolSelectedDate = date
              _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            
            defaults.set(date, forKey: Constant.MyClassConstants.selectedDate)
            Constant.MyClassConstants.vacationSearchShowDate = (date as NSDate!) as Date!
            
            if(self.requestedDateWindow != "" && self.requestedDateWindow == Constant.MyClassConstants.start) {
                
                Constant.MyClassConstants.alertWindowStartDate = date
            }
            else if(self.requestedDateWindow != "" && self.requestedDateWindow == Constant.MyClassConstants.end) {
                
                Constant.MyClassConstants.alertWindowEndDate = date
            }
            _ = self.navigationController?.popViewController(animated: true)
        }
        
       
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }
}




