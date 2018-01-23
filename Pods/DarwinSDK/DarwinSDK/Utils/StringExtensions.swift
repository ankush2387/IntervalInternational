//
//  StringExtensions.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/3/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation

extension String {
    
    func dateFromFormat(_ format:String) -> Date! {
        return createDateFormatter(format).date(from: self)
    }

	func dateFromLongFormat() -> Date! {
		return self.dateFromFormat("yyyy-MM-dd'T'HH:mm:ssXXX")
	}

    func dateFromShortFormat() -> Date! {
        return self.dateFromFormat("yyyy-MM-dd")
    }

    func indexOf(_ innerStr: String) -> String.Index? {
        return self.range(of: innerStr, options: .literal, range: nil, locale: nil)?.lowerBound
    }
    
    func trim() -> String? {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }

    fileprivate func createDateFormatter(_ format:String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let timeZone = TimeZone(identifier: "UTC") {
            dateFormatter.timeZone = timeZone
        } else {
            dateFormatter.timeZone = NSTimeZone.local
        }
        return dateFormatter
    }
    
}

