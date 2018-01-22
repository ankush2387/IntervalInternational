//
//  ExchangeStatus.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/6/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum ExchangeStatus : String {
    case CONFIRMED = "CONFIRMED"
    case RECONFIRMED = "RECONFIRMED"
    case RETRADE = "RETRADE"
    case CANCEL_AFTER = "CANCEL_AFTER"
    case PENDING = "PENDING"
    case CANCEL_BEFORE = "CANCEL_BEFORE"
    case OPEN = "OPEN"
    case UNREDEEM = "UNREDEEM"
    case DENIED = "DENIED"
    case INVALID = "INVALID"
    case UNKNOWN = "UNKNOWN"
    
    var name: String {
        return self.rawValue
    }
    
    // Helper methods for UI
    public func isThis(name : String) -> Bool {
        return self.name == name
    }

    public static func fromName(name : String) -> ExchangeStatus {
        if ExchangeStatus.CONFIRMED.name == name {
            return ExchangeStatus.CONFIRMED
        } else if ExchangeStatus.RECONFIRMED.name == name {
            return ExchangeStatus.RECONFIRMED
        } else if ExchangeStatus.RETRADE.name == name {
            return ExchangeStatus.RETRADE
        } else if ExchangeStatus.CANCEL_AFTER.name == name {
            return ExchangeStatus.CANCEL_AFTER
        } else if ExchangeStatus.PENDING.name == name {
            return ExchangeStatus.PENDING
        } else if ExchangeStatus.CANCEL_BEFORE.name == name {
            return ExchangeStatus.CANCEL_BEFORE
        } else if ExchangeStatus.UNREDEEM.name == name {
            return ExchangeStatus.UNREDEEM
        } else if ExchangeStatus.DENIED.name == name {
            return ExchangeStatus.DENIED
        } else if ExchangeStatus.INVALID.name == name {
            return ExchangeStatus.INVALID
        } else {
            return ExchangeStatus.UNKNOWN
        }
    }
    
    public func friendlyNameForUpcomingTrip() -> String {
        if (isThis(name: "CONFIRMED") || isThis(name: "RECONFIRMED")  || isThis(name: "RETRADE") ) {
            return "Confirmed"
        } else if (isThis(name: "UNREDEEM")) {
            return "Unredeemed"
        } else if (isThis(name: "CANCEL_AFTER")) {
            return "Cancelled"
        } else {
            return ""
        }
    }
    
    public func friendlyNameForRelinquishment(isDeposit:Bool) -> String {
        if (isThis(name: "CONFIRMED") || isThis(name: "RECONFIRMED")  || isThis(name: "RETRADE") ) {
            return "Confirmed"
        } else if (isThis(name: "UNREDEEM")) {
            return isDeposit ? "Unredeemed Deposit" : "Unredeemed"
        } else if (isThis(name: "CANCEL_AFTER")) {
            return "Cancelled"
        } else {
            return ""
        }
    }
}
