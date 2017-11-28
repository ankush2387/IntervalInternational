//
//  VacationSearchType.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 8/18/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum VacationSearchType : String {
    case Combined = "COMBINED"
    case Exchange = "EXCHANGE"
    case Rental = "RENTAL"
    case Unknown = "UNKNOWN"
    
    
    var name: String {
        return self.rawValue
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
        if VacationSearchType.Combined.name == name {
            return VacationSearchType.Combined
        } else if VacationSearchType.Exchange.name == name {
            return VacationSearchType.Exchange
        } else if VacationSearchType.Rental.name == name {
            return VacationSearchType.Rental
        } else {
            return VacationSearchType.Unknown
        }
    }
}
