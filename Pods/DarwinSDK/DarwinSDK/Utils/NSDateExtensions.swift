//
//  NSDateExtensions.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/21/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation

extension Date {
    
    public func stringWithShortFormatForJSON() -> String {
        return createDateFormatter("yyyy-MM-dd").string(from: self)
    }
    
    public func stringWithLongFormatForJSON() -> String {
        return createDateFormatter("yyyy-MM-dd'T'HH:mm:ssXXX").string(from: self)
    }
        
    public func transformToShortFormat() -> Date {
        let dateFormatter = createDateFormatter("yyyy-MM-dd")
        let dateAsString = dateFormatter.string(from: self)
        let newDate = dateFormatter.date(from: dateAsString)
        return newDate ?? Date()
    }
    
    public func yesterday() -> Date {
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        return calendar.date(byAdding: Calendar.Component.day, value: -1, to: self)!
    }
    
    public func tomorrow() -> Date {
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        return calendar.date(byAdding: Calendar.Component.day, value: +1, to: self)!
    }
    
    public func plusDays(_ days:Int) -> Date {
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
    
    public func minusDays(_ days:Int) -> Date {
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        return calendar.date(byAdding: .day, value: -1 * days, to: self)!
    }
    
    public func plusMonths(_ months:Int) -> Date {
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        return calendar.date(byAdding: .month, value: months, to: self)!
    }
    
    public func minusMonths(_ months:Int) -> Date {
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        return calendar.date(byAdding: .month, value: -1 * months, to: self)!
    }
    
    public func plusYears(_ years:Int) -> Date {
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        return calendar.date(byAdding: .year, value: years, to: self)!
    }
    
    public func minusYears(_ years:Int) -> Date {
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        return calendar.date(byAdding: .year, value: -1 * years, to: self)!
    }

    public func startOfMonth() -> Date {
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
    }
    
    public func endOfMonth() -> Date {
        // To get the last day of the month, add one month and subtract one day
        let endOfMonth = plusMonths(1).minusDays(1)
        return endOfMonth
    }
    
    public func withDayOfMonth(_ day:Int) -> Date {
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        return calendar.date(bySetting: .day, value: day, of: self)!
    }
    
    public func lengthOfMonth() -> Int {
        if #available(iOS 10.0, *) {
            // Calculate start and end of the current month
            let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
            let interval = calendar.dateInterval(of: .month, for: self)!
            return self.diffInDays(from: interval.start, to: interval.end)
        } else {
            // Fallback on earlier versions
            return 0
        }
    }
    
    public func monthOfYear() -> Int {
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        return calendar.component(.month, from: self)
    }
    
    public func daysBetween(to:Date) -> Int {
        return self.diffInDays(from: self, to: to)
    }
    
    public func isBefore(_ date:Date) -> Bool {
        return date > self
    }
    
    public func isAfter(_ date:Date) -> Bool {
        return date < self
    }
    
    public func diffInDays(from:Date, to:Date) -> Int {
        // Compute difference in days
        let calendar = CalendarHelperLocator.sharedInstance.provideHelper().createCalendar()
        return calendar.dateComponents([.day], from: from.transformToShortFormat(), to: to.transformToShortFormat()).day!
    }
    
    fileprivate func createDateFormatter(_ format:String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let timeZone = TimeZone(identifier: "UTC") {
            dateFormatter.timeZone = timeZone
        } else {
            dateFormatter.timeZone = NSTimeZone.local
        }
        return dateFormatter
    }
    
}
