//
//  Date+ElapsedTime.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/19/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

extension Date {
    
    /// Returns the number of minutes that have elapsed from this Date instance
    var numberOfMinutesElapsedFromDate: Int {
        return abs(Int(self.timeIntervalSinceNow)) / 60
    }
}
