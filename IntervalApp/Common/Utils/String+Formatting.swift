//
//  String+Formatting.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 3/15/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

extension String {
    
    var isNotEmpty: Bool { return !self.isEmpty }
    
    func replacingOccurrences(of string: String, with replacement: String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
}
