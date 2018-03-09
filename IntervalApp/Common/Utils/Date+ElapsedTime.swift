//
//  Date+ElapsedTime.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/19/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import DarwinSDK
import Foundation

extension Date {
    
    /// Returns the number of minutes that have elapsed from this Date instance
    var numberOfMinutesElapsedFromDate: Int {
        return abs(Int(self.timeIntervalSinceNow)) / 60
    }

    /// Returns the number of days that have elapsed from the NSDate instance
    func numberOfDaysElapsedFromToday() -> Int {
        // No Unit Test needed for this
        // This is just a wrapper around foundation functions
        let today = Date()
        let calendar = CalendarHelper().createCalendar()
        let todayDate = calendar.startOfDay(for: today)
        let passedInDate = calendar.startOfDay(for: self)
        let timeElapsed = calendar.dateComponents([.day], from: passedInDate, to: todayDate)
        return timeElapsed.day ?? 0
    }

    /// Returns the number of days remaining from date to today
    func numberOfDaysToToday() -> Int {
        // No Unit Test needed for this
        // This is just a wrapper around foundation functions
        let today = Date()
        let calendar = CalendarHelper().createCalendar()
        let todayDate = calendar.startOfDay(for: today)
        let passedInDate = calendar.startOfDay(for: self)
        let timeElapsed = calendar.dateComponents([.day], from: todayDate, to: passedInDate)
        return timeElapsed.day ?? 0
    }
}
