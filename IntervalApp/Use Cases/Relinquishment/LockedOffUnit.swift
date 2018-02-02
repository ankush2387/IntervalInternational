//
//  LockedOffUnit.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 2/4/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

struct LockedOffUnit: MultipleSelectionElement {
    let unitDetails: String
    let unitCapacity: String
    var cellTitle: String { return unitDetails }
    var cellSubtitle: String { return unitCapacity }
}
