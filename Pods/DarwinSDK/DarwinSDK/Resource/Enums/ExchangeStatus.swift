//
//  ExchangeStatus.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/6/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum ExchangeStatus : String {
    case Confirmed = "CONFIRMED"            // UpcomingTrips-Display: Confirmed
    case Reconfirmed = "RECONFIRMED"        // UpcomingTrips-Display: Confirmed
    case Retrade = "RETRADE"                // UpcomingTrips-Display: Confirmed
    case CancelAfter = "CANCEL_AFTER"       // UpcomingTrips-Display: Cancelled
    case Pending = "PENDING"                // UpcomingTrips-Display: Pending Request?
    case CancelBefore = "CANCEL_BEFORE"     // UpcomingTrips-Display: this would never show
    case Open = "OPEN"                      // UpcomingTrips-Display: this would never show
    case Unredeem = "UNREDEEM"              // UpcomingTrips-Display: this would never show
    case Denied = "DENIED"                  // UpcomingTrips-Display: ?
    case Invalid = "INVALID"                // UpcomingTrips-Display: ?
    case Unknown = "UNKNOWN"
    
    var name: String {
        return self.rawValue
    }
    
    // Helper methods for UI
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public static func fromName(name : String) -> ExchangeStatus {
        if ExchangeStatus.Confirmed.name == name {
            return ExchangeStatus.Confirmed
        } else if ExchangeStatus.Reconfirmed.name == name {
            return ExchangeStatus.Reconfirmed
        } else if ExchangeStatus.Retrade.name == name {
            return ExchangeStatus.Retrade
        } else if ExchangeStatus.CancelAfter.name == name {
            return ExchangeStatus.CancelAfter
        } else if ExchangeStatus.Pending.name == name {
            return ExchangeStatus.Pending
        } else if ExchangeStatus.CancelBefore.name == name {
            return ExchangeStatus.CancelBefore
        } else if ExchangeStatus.Unredeem.name == name {
            return ExchangeStatus.Unredeem
        } else if ExchangeStatus.Denied.name == name {
            return ExchangeStatus.Denied
        } else if ExchangeStatus.Invalid.name == name {
            return ExchangeStatus.Invalid
        } else {
            return ExchangeStatus.Unknown
        }
    }
    
    public func friendlyNameForUpcomingTrip() -> String {
        if (isThis(name: "CONFIRMED") || isThis(name: "RECONFIRMED")  || isThis(name: "RETRADE") ) {
            return "Confirmed"
        } else if (isThis(name: "CANCEL_AFTER")) {
            return "Cancelled"
        } else {
            return ""
        }
    }
    
}
