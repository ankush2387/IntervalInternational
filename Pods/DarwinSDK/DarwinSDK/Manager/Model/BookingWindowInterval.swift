//
//  BookingWindowInterval.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class BookingWindowInterval : Comparable {
    
    open var startDate : Date
    open var endDate : Date
    open var active : Bool = false
    open var fetchedBefore : Bool = false
    open var checkInDates : [String]?
    open var resortCodes : [String]?
    
    public init(checkInDate:Date) {
        // Calculate initial interval
        //self.startDate = checkInDate.minusMonths(2).withDayOfMonth(1)
        //self.endDate = checkInDate.plusMonths(1)
        //self.endDate = self.endDate.withDayOfMonth(self.endDate.lengthOfMonth())
   
        self.startDate = checkInDate.minusMonths(1).startOfMonth()
        let diff = checkInDate.monthOfYear() - Date().tomorrow().monthOfYear()
        if diff < 1 {
            self.endDate = checkInDate.plusMonths(2)
        } else {
            self.endDate = checkInDate.plusMonths(1)
        }
        self.endDate = self.endDate.withDayOfMonth(self.endDate.lengthOfMonth())
    }
    
    public init(fromDate:Date, toDate:Date) {
        self.startDate = fromDate.plusDays(0)
        self.endDate = toDate.plusDays(0)
    }

    public init(interval:BookingWindowInterval) {
        self.startDate = interval.startDate.plusDays(0)
        self.endDate = interval.endDate.plusDays(0)
        self.active = interval.active
        self.fetchedBefore = interval.fetchedBefore
        self.checkInDates = interval.checkInDates
        self.resortCodes = interval.resortCodes
    }
    
    open func hasCheckInDates() -> Bool {
        guard let checkInDates = self.checkInDates else { return false }
        return !checkInDates.isEmpty
    }
    
    open func hasResortCodes() -> Bool {
        guard let resortCodes = self.resortCodes else { return false }
        return !resortCodes.isEmpty
    }

    open func clipTo(fromDate:Date, toDate:Date) {
        if self.startDate.isBefore(fromDate) {
            self.startDate = fromDate.plusDays(0)
        }
        
        if self.endDate.isAfter(toDate) {
            self.endDate = toDate.plusDays(0)
        }
    }
    
    open func includes(date:Date) -> Bool {
        return date.isBefore(self.startDate) || date.isAfter(self.endDate) ? false : true
    }
    
    open func resetCheckInDatesAndResortCodes() {
        checkInDates = nil
        resortCodes = nil
    }
}

// Comparable implementation
public func < (lhs: BookingWindowInterval, rhs: BookingWindowInterval) -> Bool {
    return lhs.startDate.isBefore(rhs.startDate) ? true : false
}

public func > (lhs: BookingWindowInterval, rhs: BookingWindowInterval) -> Bool {
    return lhs.startDate.isAfter(rhs.startDate) ? true : false
}

public func == (lhs: BookingWindowInterval, rhs: BookingWindowInterval) -> Bool {
    return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate
}

