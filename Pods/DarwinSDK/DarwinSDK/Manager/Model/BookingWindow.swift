//
//  BookingWindow.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class BookingWindow {
    
    open var startDate : Date?
    open var endDate : Date?
    open lazy var intervals = [BookingWindowInterval]()
    open var currentInterval : BookingWindowInterval?
    
    public init(checkInDate:Date!) {
        self.calculateIntervals(checkInDate: checkInDate)
    }
    
    public init(startDate:Date!, endDate:Date!) {
        self.startDate = startDate
        self.endDate = endDate
        
        // Clear the intervals
        self.intervals = [BookingWindowInterval]()
        
        // Active interval
        let activeInterval = BookingWindowInterval(fromDate: startDate, toDate: endDate)
        activeInterval.active = true
        
        // Add unique/fix interval
        self.intervals.append(activeInterval)
    }
    
    open func getActiveInterval() -> BookingWindowInterval? {
        if (self.intervals.isEmpty) {
            return nil
        }
        
        for interval in intervals {
            if (interval.active) {
                return interval
            }
        }
        return nil
    }
    
    open func getIntervalFor(date:Date!) -> BookingWindowInterval? {
        if (self.intervals.isEmpty) {
            return nil
        }
        
        for interval in intervals {
            if (interval.includes(date: date)) {
                return interval
            }
        }
        return nil
    }
    
    open func getIntervalFor(startDate:Date!, endDate:Date!) -> BookingWindowInterval? {
        let intervalWithStartDate = self.getIntervalFor(date: startDate)
        let intervalWithEndDate = self.getIntervalFor(date: endDate)
        return (intervalWithStartDate != nil && intervalWithEndDate != nil && intervalWithStartDate == intervalWithEndDate) ? intervalWithStartDate : nil
    }
    
    open func hasIntervalBefore(interval:BookingWindowInterval) -> Bool {
        return interval.startDate!.isAfter(self.startDate!)
    }
    
    open func hasIntervalAfter(interval:BookingWindowInterval) -> Bool {
        return interval.endDate!.isBefore(self.endDate!)
    }
    
    open func getIntervalBefore(interval:BookingWindowInterval) -> BookingWindowInterval? {
        if (!self.hasIntervalBefore(interval: interval)) {
            return nil
        }
        return self.getIntervalFor(date: interval.startDate?.minusDays(1))
    }
    
    open func  getIntervalAfter(interval:BookingWindowInterval) -> BookingWindowInterval? {
        if (!self.hasIntervalAfter(interval: interval)) {
            return nil
        }
        return self.getIntervalFor(date: interval.endDate?.plusDays(1))
    }
    
    open func nextInterval() -> BookingWindowInterval? {
        if (self.intervals.isEmpty) {
            return nil
        }
    
        if (self.currentInterval == nil) {
            self.currentInterval = intervals.first
        }
    
        if (self.hasIntervalAfter(interval: self.currentInterval!)) {
            self.currentInterval = self.getIntervalAfter(interval: self.currentInterval!)
            return self.currentInterval
        }
    
        return nil
    }
    
    open func previousInterval() -> BookingWindowInterval? {
        if (self.intervals.isEmpty) {
            return nil
        }
        
        if (self.currentInterval == nil) {
            self.currentInterval = intervals.last
        }

        if (self.hasIntervalBefore(interval: self.currentInterval!)) {
            self.currentInterval = self.getIntervalBefore(interval: self.currentInterval!)
            return self.currentInterval
        }
        
        return nil
    }
    
    open func resetIntervals() {
        if (!self.intervals.isEmpty) {
            for interval in intervals {
                interval.active = false
            }
        }
    }
    
    fileprivate func calculateIntervals(checkInDate:Date?) {
        // Clear the intervals
        var theCheckInDate = checkInDate
        self.intervals = [BookingWindowInterval]()
    
        // First, set the start and end dates:
        // The start date is always today + 1
        // The end date is 2 years after the start date
        self.startDate = Date().plusDays(1)
        self.endDate = self.startDate?.plusYears(2)
    
        // The checkInDate is required. If not provided, set it to 7 days after the start date
        if (theCheckInDate == nil) {
            theCheckInDate = (self.startDate?.plusDays(7))!
        }
    
        // Make sure the checkInDate is between the start and end dates
        if (theCheckInDate?.isBefore(self.startDate!))! {
            theCheckInDate = self.startDate?.plusDays(7)
        } else if (theCheckInDate?.isAfter(self.endDate!))! {
            theCheckInDate = self.endDate?.minusDays(7)
        }
    
        // Next, create the first interval based on the checkInDate.
        // This is important, so that we get the best spread surrounding the requested checkInDate.
        // The other option is just to calculate the intervals evenly between the start and end dates,
        // but that will not yield the best results for the Member.
        self.currentInterval = BookingWindowInterval(checkInDate: theCheckInDate)
        self.currentInterval?.active = true
        self.currentInterval?.clipTo(fromDate: self.startDate, toDate: self.endDate)
    
        // Next, fill in the intervals before the current interval
        var cursorInterval = BookingWindowInterval(interval: self.currentInterval)
        while (self.hasIntervalBefore(interval: cursorInterval)) {
            // Create a new Interval
            let newStartDate = cursorInterval.startDate?.minusMonths(3)
            var newEndDate = newStartDate?.plusMonths(2)
            newEndDate = newEndDate?.withDayOfMonth((newEndDate?.lengthOfMonth())!)
    
            let newInterval = BookingWindowInterval(fromDate: newStartDate, toDate: newEndDate)
            newInterval.clipTo(fromDate: self.startDate, toDate: self.endDate)
    
            intervals.append(newInterval)
            cursorInterval = newInterval
        }
    
        self.intervals.append(self.currentInterval!)
    
        // Next, fill in the intervals after the current interval
        cursorInterval = BookingWindowInterval(interval: self.currentInterval)
        while (self.hasIntervalAfter(interval: cursorInterval)) {
            // Create a new Interval
            let newStartDate = cursorInterval.endDate?.plusDays(1)
            var newEndDate = newStartDate?.plusMonths(2)
            newEndDate = newEndDate?.withDayOfMonth(newEndDate!.lengthOfMonth())
    
            let newInterval = BookingWindowInterval(fromDate: newStartDate, toDate: newEndDate)
            newInterval.clipTo(fromDate: self.startDate, toDate: self.endDate)
    
            self.intervals.append(newInterval)
            cursorInterval = newInterval
        }
    
        // Finally, sort the intervals
        self.intervals.sort()
    }
    
}
