//
//  Date+Format.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/17/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import DarwinSDK
import Foundation

var hourFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    formatter.timeZone = TimeZone.autoupdatingCurrent
    return formatter
}()

var weekdayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    formatter.timeZone = TimeZone.autoupdatingCurrent
    return formatter
}()

var shortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = DateFormatter.Style.short
    formatter.timeStyle = DateFormatter.Style.none
    formatter.timeZone = TimeZone.autoupdatingCurrent
    return formatter
}()

extension Date {
    
    // Create NSDate with a UNIX timestamp for this instance
    init? (epochSecondsSince1970: String) {
        
        guard let milliSeconds = Double(epochSecondsSince1970) else {
            return nil
        }
        
        // Calculates the numbers of seconds the string was created after UNIX inception 1970.
        self.init(timeIntervalSince1970: milliSeconds/1000.0)
    }
    
    var intervalShortDateFormat: String {
        return "yyyy-MM-dd"
    }

    static var intervalShortDateFormat: String {
        return "yyyy-MM-dd"
    }
    
    func intervalShortDate() -> String {
        return self.formatDateAs(intervalShortDateFormat)
    }
    
    func shortDateFormat() -> String {
        
        return self.formatDateAs("MMMM dd, yyyy")
    }
    
    func shortDateTimeFormat() -> String {
        
        return self.formatDateAs("MM/dd/yyyy hh:mm a")
    }
    
    func mediumDateTimeFormat() -> String {
        
        return self.formatDateAs("MMMM dd yyyy hh:mm a")
    }
    
    func longUTCDateFormat() -> String {
        
        return self.formatDateAs("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    }
    
    func formatDateAs(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
    
    static func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = intervalShortDateFormat
        return dateFormatter.date(from: dateString)
    }
}
