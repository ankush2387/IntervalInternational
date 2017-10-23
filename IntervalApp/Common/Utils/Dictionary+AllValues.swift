//
//  Dictionary+AllValues.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/18/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

extension Dictionary {

    init (_ pairs: [Element]) {
        self.init()
        for (key, value) in pairs {
            self[key] = value
        }
    }

    /// Lets the caller iterate through the dictionary elements via a (key, value) tuple, and transforms the values within it's closure. 
    /// - Returns: the transformed elements
    func mapPairs<OutKey: Hashable, OutValue>(transform: (Element) throws -> (OutKey, OutValue)) rethrows -> [OutKey: OutValue] {
        // swiftlint:disable:next syntactic_sugar
        return Dictionary<OutKey, OutValue> (try map(transform))
    }
}
