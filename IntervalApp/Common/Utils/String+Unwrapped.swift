//
//  String+Unwrapped.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/13/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

extension Optional {

    var unwrappedString: String {

        guard let unwrappedSelf = self as? String else {
            return ""
        }

        return unwrappedSelf
    }
}
