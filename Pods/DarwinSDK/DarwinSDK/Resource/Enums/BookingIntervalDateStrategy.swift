//
//  BookingIntervalDateStrategy.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 8/18/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum BookingIntervalDateStrategy : String {
    case First = "FIRST"
    case Middle = "MIDDLE"
    case Nearest = "NEAREST"
    case Unknown = "UNKNOWN"
    
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
        if BookingIntervalDateStrategy.First.name == name {
            return BookingIntervalDateStrategy.First
        } else if BookingIntervalDateStrategy.Middle.name == name {
            return BookingIntervalDateStrategy.Middle
        } else if BookingIntervalDateStrategy.Nearest.name == name {
            return BookingIntervalDateStrategy.Nearest
        } else {
            return BookingIntervalDateStrategy.Unknown
        }
    }
}
