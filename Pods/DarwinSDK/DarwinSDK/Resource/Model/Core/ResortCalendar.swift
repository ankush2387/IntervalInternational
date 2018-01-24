//
//  ResortCalendar.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/25/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ResortCalendar {
    
    open var checkInDate : String?
    open var checkOutDate : String?
    open var dayOfWeek : String?
    open var weekNumber : String?
    open var tdiColorValue : Int = 0
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.checkInDate = json["checkInDate"].string ?? ""
        self.checkOutDate = json["checkOutDate"].string ?? ""
        self.dayOfWeek = json["dayOfWeek"].string ?? ""
        self.weekNumber = json["weekNumber"].string ?? ""
        self.tdiColorValue = json["tdiColorValue"].intValue
    }
    
    open func getDaysUntilCheckInDate() -> Int {
        if let checkInDate = self.checkInDate {
            let today = Date()
            return today.daysBetween(to: checkInDate.dateFromShortFormat()!)
        }
        return -1 // Passed
    }
    
}
