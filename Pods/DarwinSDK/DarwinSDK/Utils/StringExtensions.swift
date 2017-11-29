//
//  StringExtensions.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/3/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation

extension String {
    
	func dateFromLongFormat() -> Date! {
		return self.dateFromFormat("yyyy-MM-dd'T'HH:mm:ssXXX")
	}
	
    func dateFromShortFormat() -> Date! {
        return self.dateFromFormat("yyyy-MM-dd")
    }

    func dateFromFormat(_ format:String) -> Date! {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		
		return dateFormatter.date(from: self)
	}
    
    func indexOf(_ innerStr: String) -> String.Index? {
        return self.range(of: innerStr, options: .literal, range: nil, locale: nil)?.lowerBound
    }
    
    func trim() -> String? {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
}

