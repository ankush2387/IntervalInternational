//
//  CreditCardType.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum CreditCardType : String {
    case AmericanExpress = "AX"
    case DinersClub = "DC"
    case DiscoverCard = "DS"
    case MasterCard = "MC"
    case Visa = "VS"
    case Unknown = "UNKNOWN"
    
    var name: String {
        return self.rawValue
    }
    
    // Helper methods for UI
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public static func fromName(name : String) -> CreditCardType {
        if CreditCardType.AmericanExpress.name == name {
            return CreditCardType.AmericanExpress
        } else if CreditCardType.DinersClub.name == name {
            return CreditCardType.DinersClub
        } else if CreditCardType.DiscoverCard.name == name {
            return CreditCardType.DiscoverCard
        } else if CreditCardType.MasterCard.name == name {
            return CreditCardType.MasterCard
        } else if CreditCardType.Visa.name == name {
            return CreditCardType.Visa
        } else {
            return CreditCardType.Unknown
        }
    }

}

