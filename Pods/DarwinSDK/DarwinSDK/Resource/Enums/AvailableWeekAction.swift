//
//  AvailableWeekAction.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/9/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum AvailableWeekAction : String {
    case Rentals = "GETAWAYS"
    case Shop = "SHOP"
    case ShopShortStay = "SHOP_SHORT_STAYS"
    case Request = "REQUEST"
    case Deposit = "DEPOSIT"
    case DepositPoints = "DEPOSIT_POINTS"
    case Accept = "ACCEPT"
    case FutureUse = "FUTURE_USE"
    case DeclineRegular = "DECLINE_REGULAR"
    case DeclineMatch = "DECLINE_MATCH"
    case DeclineUnredeem = "DECLINE_UNREDEEM"
    case DeclineCancelBefore = "DECLINE_CANCEL_BEFORE"
    case AccomodationCertificateExtension = "ACCOMMDATION_CERTIFICATE_EXTENSION"
    case Unknown = "UNKNOWN"
    
    var name: String {
        return self.rawValue
    }
    
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public static func fromName(name : String) -> AvailableWeekAction {
        if AvailableWeekAction.Rentals.name == name {
            return AvailableWeekAction.Rentals
        } else if AvailableWeekAction.Shop.name == name {
            return AvailableWeekAction.Shop
        } else if AvailableWeekAction.ShopShortStay.name == name {
            return AvailableWeekAction.ShopShortStay
        } else if AvailableWeekAction.AccomodationCertificateExtension.name == name {
            return AvailableWeekAction.AccomodationCertificateExtension
        } else {
            return AvailableWeekAction.Unknown
        }
    }

}
