//
//  VacationSearchType.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 8/18/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum VacationSearchType : String {
    case EXCHANGE = "EXCHANGE"   // weigth = 3
    case COMBINED = "COMBINED"   // weigth = 2
    case RENTAL = "RENTAL"       // weigth = 1
    case UNKNOWN = "UNKNOWN"     // weigth = 0
    
    static let weigthMapper: [VacationSearchType: Int] = [
        .EXCHANGE: 3,
        .COMBINED: 2,
        .RENTAL: 1,
        .UNKNOWN: 0
    ]
    
    public var name: String {
        return self.rawValue
    }
    
    public var weigth: Int {
        return VacationSearchType.weigthMapper[self]!
    }
    
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public func isCombined() -> Bool {
        return isThis(name: "COMBINED")
    }
    
    public func isExchange() -> Bool {
        return isThis(name: "EXCHANGE")
    }
    
    public func isRental() -> Bool {
        return isThis(name: "RENTAL")
    }
    
    public static func fromName(name : String) -> VacationSearchType {
        if VacationSearchType.COMBINED.name == name {
            return VacationSearchType.COMBINED
        } else if VacationSearchType.EXCHANGE.name == name {
            return VacationSearchType.EXCHANGE
        } else if VacationSearchType.RENTAL.name == name {
            return VacationSearchType.RENTAL
        } else {
            // Fallback
            return VacationSearchType.UNKNOWN
        }
    }
}

