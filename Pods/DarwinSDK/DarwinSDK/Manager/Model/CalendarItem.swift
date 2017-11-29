//
//  CalendarItem.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class CalendarItem {
    
    open var intervalStartDate : String?
    open var intervalEndDate : String?
    open var checkInDate : String?
    open var isInterval : Bool?
    open var isIntervalAvailable : Bool?
    
    // Create a Range of Dates
    public init(intervalStartDate:String, intervalEndDate:String) {
        self.intervalStartDate = intervalStartDate
        self.intervalEndDate = intervalEndDate
        self.isInterval = self.intervalStartDate != nil && self.intervalEndDate != nil && self.checkInDate == nil;
        self.isIntervalAvailable = self.isInterval;
    }
    
    // Create a Single CheckIn Date
    public init(checkInDate:String) {
        self.checkInDate = checkInDate;
        self.isInterval = self.intervalStartDate != nil && self.intervalEndDate != nil && self.checkInDate == nil;
        self.isIntervalAvailable = self.isInterval;
    }
    
    open func markIntervalAsNotAvailable() {
        self.isIntervalAvailable = false;
    }
    
}

