//
//  ComputationHelper.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

protocol ComputationHelper { }

extension ComputationHelper {
    /// Rotates the index by one. Will overflow to the beggining of the range if index is greater than range
    func rotate(_ index: Int, within range: CountableRange<Int>) -> Int {

        if range.contains(index) {
            return index + 1
        } else {
            return range.first ?? 0
        }
    }
}
