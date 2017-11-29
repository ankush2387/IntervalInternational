//
//  NSDateExtensions.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/21/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation

extension Date {
    
    func stringWithShortFormatForJSON() -> String! {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: self)
    }
    
    func stringWithLongFormatForJSON() -> String! {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
        
        return dateFormatter.string(from: self)
    }
    
    func transformToShortFormat() -> Date! {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateAsString = dateFormatter.string(from: self);
        return dateFormatter.date(from: dateAsString)
    }
    
    func yesterday() -> Date {
        return Calendar.current.date(byAdding: Calendar.Component.day, value: -1, to: self)!.transformToShortFormat()!
        //return Calendar(identifier: .gregorian).date(byAdding: Calendar.Component.day, value: -1, to: self)!
    }
    
    func plusDays(_ days:Int!) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!.transformToShortFormat()
    }
    
    func minusDays(_ days:Int!) -> Date {
        return Calendar.current.date(byAdding: .day, value: -1 * days, to: self)!.transformToShortFormat()!
    }
    
    func plusMonths(_ months:Int!) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self)!.transformToShortFormat()!
    }
    
    func minusMonths(_ months:Int!) -> Date {
        return Calendar.current.date(byAdding: .month, value: -1 * months, to: self)!.transformToShortFormat()!
    }
    
    func plusYears(_ years:Int!) -> Date {
        return Calendar.current.date(byAdding: .year, value: years, to: self)!.transformToShortFormat()!
    }
    
    func minusYears(_ years:Int!) -> Date {
        return Calendar.current.date(byAdding: .year, value: -1 * years, to: self)!.transformToShortFormat()!
    }
    
    func withDayOfMonth(_ day:Int!) -> Date {
        return Calendar.current.date(bySetting: .day, value: day, of: self)!.transformToShortFormat()!
    }
    
    func lengthOfMonth() -> Int {
        if #available(iOS 10.0, *) {
            // Calculate start and end of the current month
            let interval = Calendar.current.dateInterval(of: .month, for: self)!
            return self.diffInDays(from: interval.start, to: interval.end)
        } else {
            // Fallback on earlier versions
            return 0
        }
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
    
    private func diffInDays(from:Date, to:Date) -> Int {
        // Compute difference in days
        return Calendar.current.dateComponents([.day], from: from, to: to).day!
    }
    
}
