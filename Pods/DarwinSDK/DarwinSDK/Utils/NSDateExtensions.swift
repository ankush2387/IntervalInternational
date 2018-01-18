//
//  NSDateExtensions.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/21/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation

extension Date {
    
    func stringWithShortFormatForJSON() -> String {
        return createDateFormatter("yyyy-MM-dd").string(from: self)
    }
    
    func stringWithLongFormatForJSON() -> String {
        return createDateFormatter("yyyy-MM-dd'T'HH:mm:ssXXX").string(from: self)
    }
    
    func transformToShortFormat() -> Date {
        let dateFormatter = createDateFormatter("yyyy-MM-dd")
        let dateAsString = dateFormatter.string(from: self)
        let newDate = dateFormatter.date(from: dateAsString)
        return newDate ?? Date()
    }
    
    func yesterday() -> Date {
        return createCalendar().date(byAdding: Calendar.Component.day, value: -1, to: self)!
    }
    
    func tomorrow() -> Date {
        return createCalendar().date(byAdding: Calendar.Component.day, value: +1, to: self)!
    }
    
    func plusDays(_ days:Int) -> Date {
        return createCalendar().date(byAdding: .day, value: days, to: self)!
    }
    
    func minusDays(_ days:Int) -> Date {
        return createCalendar().date(byAdding: .day, value: -1 * days, to: self)!
    }
    
    func plusMonths(_ months:Int) -> Date {
        return createCalendar().date(byAdding: .month, value: months, to: self)!
    }
    
    func minusMonths(_ months:Int) -> Date {
        return createCalendar().date(byAdding: .month, value: -1 * months, to: self)!
    }
    
    func plusYears(_ years:Int) -> Date {
        return createCalendar().date(byAdding: .year, value: years, to: self)!
    }
    
    func minusYears(_ years:Int) -> Date {
        return createCalendar().date(byAdding: .year, value: -1 * years, to: self)!
    }

    func startOfMonth() -> Date {
        let startOfMonth = createCalendar().date(from: createCalendar().dateComponents([.year, .month], from: self))
        return startOfMonth!
    }
    
    func endOfMonth() -> Date {
        // To get the last day of the month, add one month and subtract one day
        let endOfMonth = plusMonths(1).minusDays(1)
        return endOfMonth
    }
    
    func withDayOfMonth(_ day:Int) -> Date {
        return createCalendar().date(bySetting: .day, value: day, of: self)!
    }
    
    func lengthOfMonth() -> Int {
        if #available(iOS 10.0, *) {
            // Calculate start and end of the current month
            let interval = createCalendar().dateInterval(of: .month, for: self)!
            return self.diffInDays(from: interval.start, to: interval.end)
        } else {
            // Fallback on earlier versions
            return 0
        }
    }
    
    func monthOfYear() -> Int {
        return createCalendar().component(.month, from: self)
    }
    
    func daysBetween(to:Date) -> Int {
        return self.diffInDays(from: self, to: to)
    }
    
    func isBefore(_ date:Date) -> Bool {
        return date > self
    }
    
    func isAfter(_ date:Date) -> Bool {
        return date < self
    }
    
    fileprivate func diffInDays(from:Date, to:Date) -> Int {
        // Compute difference in days
        return createCalendar().dateComponents([.day], from: from.transformToShortFormat(), to: to.transformToShortFormat()).day!
    }
    
    fileprivate func createDateFormatter(_ format:String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone.local
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        //dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }
    
    fileprivate func createCalendar() -> Calendar {
        let calendar = Calendar(identifier: .gregorian) // Calendar.current
        return calendar
    }

}
