//
//  AvailableWeekAction.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/9/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum AvailableWeekAction : String {
    case RENTALS = "GETAWAYS"
    case SHOP = "SHOP"
    case SHOP_SHORT_STAYS = "SHOP_SHORT_STAYS"
    case REQUEST = "REQUEST"
    case DEPOSIT = "DEPOSIT"
    case DEPOSIT_POINTS = "DEPOSIT_POINTS"
    case ACCEPT = "ACCEPT"
    case EXTEND_DEPOSIT = "EXTEND_DEPOSIT"
    case DECLINE_REGULAR = "DECLINE_REGULAR"
    case DECLINE_MATCH = "DECLINE_MATCH"
    case DECLINE_UNREDEEM = "DECLINE_UNREDEEM"
    case DECLINE_CANCEL_BEFORE = "DECLINE_CANCEL_BEFORE"
    case ACCOMMDATION_CERTIFICATE_EXTENSION = "ACCOMMDATION_CERTIFICATE_EXTENSION"
    case FUTURE_USE = "FUTURE_USE"
    case UNKNOWN = "UNKNOWN"
    
    var name: String {
        return self.rawValue
    }
    
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public static func fromName(name : String) -> AvailableWeekAction {
        if AvailableWeekAction.RENTALS.name == name {
            return AvailableWeekAction.RENTALS
        } else if AvailableWeekAction.SHOP.name == name {
            return AvailableWeekAction.SHOP
        } else if AvailableWeekAction.SHOP_SHORT_STAYS.name == name {
            return AvailableWeekAction.SHOP_SHORT_STAYS
        } else if AvailableWeekAction.REQUEST.name == name {
            return AvailableWeekAction.REQUEST
        } else if AvailableWeekAction.DEPOSIT.name == name {
            return AvailableWeekAction.DEPOSIT
        } else if AvailableWeekAction.DEPOSIT_POINTS.name == name {
            return AvailableWeekAction.DEPOSIT_POINTS
        } else if AvailableWeekAction.ACCEPT.name == name {
            return AvailableWeekAction.ACCEPT
        } else if AvailableWeekAction.EXTEND_DEPOSIT.name == name {
            return AvailableWeekAction.EXTEND_DEPOSIT
        } else if AvailableWeekAction.DECLINE_REGULAR.name == name {
            return AvailableWeekAction.DECLINE_REGULAR
        } else if AvailableWeekAction.DECLINE_MATCH.name == name {
            return AvailableWeekAction.DECLINE_MATCH
        } else if AvailableWeekAction.DECLINE_UNREDEEM.name == name {
            return AvailableWeekAction.DECLINE_UNREDEEM
        } else if AvailableWeekAction.DECLINE_CANCEL_BEFORE.name == name {
            return AvailableWeekAction.DECLINE_CANCEL_BEFORE
        } else if AvailableWeekAction.ACCOMMDATION_CERTIFICATE_EXTENSION.name == name {
            return AvailableWeekAction.ACCOMMDATION_CERTIFICATE_EXTENSION
        } else if AvailableWeekAction.FUTURE_USE.name == name {
            return AvailableWeekAction.FUTURE_USE
        } else {
            return AvailableWeekAction.UNKNOWN
        }
    }

}
