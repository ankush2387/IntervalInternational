//
//  String+DateFormat.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/17/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

import Foundation

enum DateFormat { case shortDateFormat, mediumDateTimeFormat }

extension String {
    
    func dateTimeStringLocalizer() -> String {
        return self.dateTimeStringLocalizer(TimeZone.autoupdatingCurrent, format: .mediumDateTimeFormat)
    }
    
    func shortDateFormatLocalized() -> String {
        return dateTimeStringLocalizer(TimeZone.autoupdatingCurrent, format: .shortDateFormat)
    }
    
    /**
     Provides a date string from a date string without any consideration of the devices current
     timezone.  This is useful for Birthdates and other dates where you want the explicit date
     specified in the date string.  The input string MUST be from the "Zulu" timezone aka UTC+0.
     
     - returns: If the input string specifies a non-Zulu TZ offset then the same string will be returned.
     Otherwise the format is Januaary 1, 2016.
     */
    func shortDateFormatUnlocalized() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.timeZone = TimeZone(identifier: "UTC")
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = inputFormatter.date(from: self) else {
            return self
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.timeZone = TimeZone(abbreviation: "UTC")
        outputFormatter.dateFormat = "MMMM dd, yyyy"
        return outputFormatter.string(from: date)
    }
    
    /**
     Provides a date string from a date string without any consideration of the devices current
     timezone.  This is useful for Birthdates and other dates where you want the explicit date
     specified in the date string.  The input string MUST be from the "Zulu" timezone aka UTC+0.
     
     - returns: If the input string specifies a non-Zulu TZ offset then the same string will be returned.
     Otherwise the format is 01/01/2016.
     */
    
    func shortDateNumberFormatUnlocalized() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.timeZone = TimeZone(identifier: "UTC")
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = inputFormatter.date(from: self) else {
            return self
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.timeZone = TimeZone(abbreviation: "UTC")
        outputFormatter.dateFormat = "MM/dd/yyyy"
        return outputFormatter.string(from: date)
    }
    
    func dateTimeStringLocalizer(_ timezone: TimeZone, format: DateFormat) -> String {
        // Most common date formats used in the world. Add to Array for additional formats.
        // It's best to only add those with the timezone extensions at the end.
        
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss ZZZ"
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timezone
        
        // Test for date formats.
        for dateFormat in dateFormats {
            
            dateFormatter.dateFormat = dateFormat
            
            if let dateNotNil = dateFormatter.date(from: self) {
                
                switch format {
                    
                case .mediumDateTimeFormat:
                    return dateNotNil.mediumDateTimeFormat()
                    
                case .shortDateFormat:
                    return dateNotNil.shortDateFormat()
                }
            }
        }
        
        // Test for Epoch seconds from 1970
        if let newDate = Date(epochSecondsSince1970: self) {
            return String(describing: newDate).dateTimeStringLocalizer()
        }
        
        //Final return if all else fails: returns unmodified string
        return self
    }
    
    func dateFromString(for format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}
