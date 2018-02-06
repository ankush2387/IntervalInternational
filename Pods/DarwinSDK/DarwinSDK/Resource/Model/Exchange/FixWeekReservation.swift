//
//  FixWeekReservation.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/25/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class FixWeekReservation {
    
    open var reservationNumber : String?
    open var checkInDate : String?
    open var weekNumber : String?
    open var resort : Resort?
    open var unit : InventoryUnit?
    
    public init() {
    }

    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()

        if let reservationNumber = self.reservationNumber, !reservationNumber.isEmpty {
            dictionary["reservationNumber"] = reservationNumber as AnyObject?
        }
        if let checkInDate = self.checkInDate, !checkInDate.isEmpty {
            dictionary["checkInDate"] = checkInDate as AnyObject?
        }
        if let weekNumber = self.weekNumber, !weekNumber.isEmpty {
            dictionary["weekNumber"] = weekNumber as AnyObject?
        }
        if let resort = self.resort {
            dictionary["resort"] = self.resortToDictionary(resort: resort) as AnyObject?
        }
        if let unit = self.unit {
            dictionary["unit"] = self.unitToDictionary(unit: unit) as AnyObject?
        }

        return dictionary
    }
    
    private func resortToDictionary(resort: Resort?) -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["code"] = resort?.resortCode as AnyObject?
        return dictionary
    }
    
    private func unitToDictionary(unit: InventoryUnit?) -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["unitNumber"] = unit?.unitNumber as AnyObject?
        dictionary["unitSize"] = unit?.unitSize as AnyObject?
        return dictionary
    }
    
}
