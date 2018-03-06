//
//  InventoryUnit+UI.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 2/21/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import DarwinSDK

extension InventoryUnit {
    var unitDetailsUIFormatted: String {
        var unitDetails = ""

        if let unitSize = UnitSize(rawValue: unitSize.unwrappedString) {
            unitDetails = unitSize.friendlyName()
        }

        if let kitchenType = KitchenType(rawValue: kitchenType.unwrappedString) {
            unitDetails += ", \(kitchenType.friendlyName())"
        }

        if let unitNumber = unitNumber {
            unitDetails += ", \(unitNumber)"
        }

        return unitDetails.localized()
    }

    var unitCapacityUIFormatted: String {
        return "Sleeps \(tradeOutCapacity)".localized()
    }
}
