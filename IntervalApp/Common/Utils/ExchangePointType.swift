//
//  ExchangePointType.swift
//  IntervalApp
//
//  Created by Chetu on 05/04/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

public enum ExchangePointType : String {
    case CLUBPOINTS = "Club Points"
    case CIGPOINTS = "CIG Points"
    case UNKNOWN = "UNKNOWN"

    public var name: String {
        return self.rawValue
    }

    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public func isClubPoints() -> Bool {
        return isThis(name: "Club Points")
    }
    
    public func isCIGPoint() -> Bool {
        return isThis(name: "CIG Points")
    }
    
    public static func fromName(name : String) -> ExchangePointType {
        if ExchangePointType.CLUBPOINTS.name == name {
            return ExchangePointType.CLUBPOINTS
        } else if ExchangePointType.CIGPOINTS.name == name {
            return ExchangePointType.CIGPOINTS
        } else {
            // Fallback
            return ExchangePointType.UNKNOWN
        }
    }
}
