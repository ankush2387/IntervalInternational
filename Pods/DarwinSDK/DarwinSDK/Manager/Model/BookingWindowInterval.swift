//
//  BookingWindowInterval.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class BookingWindowInterval : Comparable {
    
    open var startDate : Date?
    open var endDate : Date?
    open var active : Bool = false
    open var fetchedBefore : Bool = false
    open var checkInDates : [String]?
    open var resortCodes : [String]?
    
    public init(checkInDate:Date!) {
        self.calculateInitialInterval(checkInDate: checkInDate)
    }
    
    public init(fromDate:Date!, toDate:Date!) {
        self.startDate = fromDate.plusDays(0);
        self.endDate = toDate.plusDays(0);
    }

    public convenience init(interval:BookingWindowInterval!) {
        self.init(fromDate: interval.startDate, toDate: interval.endDate)
        self.active = interval.active
        self.fetchedBefore = interval.fetchedBefore
        self.checkInDates = interval.checkInDates
        self.resortCodes = interval.resortCodes
    }
    
    open func hasCheckInDates() -> Bool {
        return self.checkInDates != nil && (self.checkInDates!.count) > 0
    }
    
    open func hasResortCodes() -> Bool {
        return self.resortCodes != nil && (self.resortCodes!.count) > 0
    }
    
    open func calculateInitialInterval(checkInDate:Date!) {
        self.startDate = checkInDate.minusMonths(2).withDayOfMonth(1)
        self.endDate = checkInDate.plusMonths(1)
        self.endDate = self.endDate?.withDayOfMonth((self.endDate?.lengthOfMonth())!)
    }
    
    open func clipTo(fromDate:Date!, toDate:Date!) {
        if (self.startDate == nil) {
            self.startDate = fromDate.plusDays(0)
        }
    
        if (self.endDate == nil) {
            self.endDate = toDate.plusDays(0)
        }
        
        if (self.startDate?.isBefore(fromDate))! {
            self.startDate = fromDate.plusDays(0)
        }
        
        if (self.endDate?.isAfter(toDate))! {
            self.endDate = toDate.plusDays(0)
        }
    }
    
    open func includes(date:Date!) -> Bool {
        if (date == self.startDate) {
            return true
        }
        
        if (date.isBefore(self.startDate!)) {
            return false
        }
    
        if (date.isAfter(self.endDate!)) {
            return false
        }
    
        return true
    }
}

// Comparable implementation
public func < (lhs: BookingWindowInterval, rhs: BookingWindowInterval) -> Bool {
    return (lhs.startDate?.isBefore(rhs.startDate!))! ? true : false
}

public func > (lhs: BookingWindowInterval, rhs: BookingWindowInterval) -> Bool {
    return (lhs.startDate?.isAfter(rhs.startDate!))! ? true : false
}

public func == (lhs: BookingWindowInterval, rhs: BookingWindowInterval) -> Bool {
    return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate
}

