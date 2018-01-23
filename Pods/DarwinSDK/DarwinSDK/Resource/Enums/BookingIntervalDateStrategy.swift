//
//  BookingIntervalDateStrategy.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 8/18/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum BookingIntervalDateStrategy : String {
    case FIRST = "FIRST"
    case MIDDLE = "MIDDLE"
    case NEAREST = "NEAREST"
    
    var name: String {
        return self.rawValue
    }
    
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public func isFirst() -> Bool {
        return isThis(name: "FIRST")
    }
    
    public func isMiddle() -> Bool {
        return isThis(name: "MIDDLE")
    }
    
    public func isNearest() -> Bool {
        return isThis(name: "NEAREST")
    }
    
    public static func fromName(name : String) -> BookingIntervalDateStrategy {
        if BookingIntervalDateStrategy.FIRST.name == name {
            return BookingIntervalDateStrategy.FIRST
        } else if BookingIntervalDateStrategy.MIDDLE.name == name {
            return BookingIntervalDateStrategy.MIDDLE
        } else if BookingIntervalDateStrategy.NEAREST.name == name {
            return BookingIntervalDateStrategy.NEAREST
        } else {
            // Fallback
            return BookingIntervalDateStrategy.FIRST
        }
    }
}
