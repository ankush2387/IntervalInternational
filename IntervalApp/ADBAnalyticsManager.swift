//
//  ADBAnalyticsManager.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/11/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

struct ADBAnalyticsManager {
    
    // MARK: - Public functions
    func sendAnalyticEvar(withIdentifier: OmnitureEvar, data: [AnyHashable: Any]) {
        ADBMobile.trackAction(withIdentifier.value, data: data)
    }
    
    func sendAnalyticEvent(withIdentifier: OmnitureEvent, data: [AnyHashable: Any]) {
        ADBMobile.trackAction(withIdentifier.value, data: data)
    }
    
    func sendAnalytics(withIdentifier: OmnitureIdentifier, data: [AnyHashable: Any]) {
        ADBMobile.trackAction(withIdentifier.value, data: data)
    }
}
