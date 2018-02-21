//
//  Relinquishment+Flags.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 2/21/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import DarwinSDK

extension Relinquishment {
    var hasLockOffUnits: Bool {
        return lockOffUnits?.isEmpty == false
    }
}
