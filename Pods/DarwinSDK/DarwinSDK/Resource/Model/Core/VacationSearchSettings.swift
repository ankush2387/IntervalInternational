//
//  VacationSearchSettings.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 8/18/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class VacationSearchSettings {
    
    open lazy var vacationSearchTypes = [String]() // VacationSearchType
    open var collapseBookingIntervalsOnChange : Bool = true
    open var bookingIntervalDateStrategy : String? // BookingIntervalDateStrategy
    
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        if json["searchTabs"].exists() {
            let searchTabsArray:[JSON] = json["searchTabs"].arrayValue
            self.vacationSearchTypes = searchTabsArray.map { $0.string! }
        }
        
        self.collapseBookingIntervalsOnChange = json["collapseBookingIntervalsOnChange"].boolValue
        self.bookingIntervalDateStrategy = json["bookingIntervalDateStrategy"].string ?? "NEAREST"
    }
    
}
