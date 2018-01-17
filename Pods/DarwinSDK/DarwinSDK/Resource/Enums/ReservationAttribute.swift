//
//  ReservationAttribute.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/12/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

public enum ReservationAttribute : String {
    case RESORT_CLUB = "RESORT_CLUB"
    case RESERVATION_NUMBER = "RESERVATION_NUMBER"
    case UNIT_NUMBER = "UNIT_NUMBER"
    case CHECK_IN_DATE = "CHECK_IN_DATE"
    case UNKNOWN = "UNKNOWN"
    
    var name: String {
        return self.rawValue
    }
    
    // Helper methods for UI
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public static func fromName(name : String) -> ReservationAttribute {
        if ReservationAttribute.RESORT_CLUB.name == name {
            return ReservationAttribute.RESORT_CLUB
        } else if ReservationAttribute.RESERVATION_NUMBER.name == name {
            return ReservationAttribute.RESERVATION_NUMBER
        } else if ReservationAttribute.UNIT_NUMBER.name == name {
            return ReservationAttribute.UNIT_NUMBER
        } else if ReservationAttribute.CHECK_IN_DATE.name == name {
            return ReservationAttribute.CHECK_IN_DATE
        } else {
            return ReservationAttribute.UNKNOWN
        }
    }
}
