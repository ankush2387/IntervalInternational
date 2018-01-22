//
//  CalendarHelper.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/18/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

public struct CalendarHelper {
    
    public init() {
    }

    public func createCalendar() -> Calendar {
        var calendar = Calendar.current
        if let timeZone = TimeZone(identifier: "UTC") {
            calendar.timeZone = timeZone
        } else {
            calendar.timeZone = NSTimeZone.local
        }
        return calendar
    }

}

// Protocol to hide our implementation of our Singleton.
public protocol CalendarHelperLocatorProtocol {
    func provideHelper() -> CalendarHelper
}

// Singleton implementation for the CalendarHelperLocatorProtocol.
// Use an enum with a single case that implement our protocol.
public enum CalendarHelperLocator: CalendarHelperLocatorProtocol {
    case sharedInstance
    
    public func provideHelper() -> CalendarHelper {
        return CalendarHelper()
    }
}
