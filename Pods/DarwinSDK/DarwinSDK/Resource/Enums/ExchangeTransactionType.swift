//
//  ExchangeTransactionType.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/6/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum ExchangeTransactionType : String {
    case Rental = "RENTAL"                          // UpcomingTrips-Display: Getaway
    case Regular_Exchange = "SHOP"                  // UpcomingTrips-Display: Exchange
    case ShortStay_Exchange = "SHORT_STAY"          // UpcomingTrips-Display: ShortStay Exchange
    case Cruise_Exchange = "CRUISE_EXCHANGE"        // UpcomingTrips-Display: Cruise Exchange
    case Hotel_Exchange = "HOTEL_EXCHANGE"          // UpcomingTrips-Display: Hotel Exchange
    case Full_Fee_Retrade = "FULL_FEE-RETRADE"      // UpcomingTrips-Display: Full Fee Retrade
    case Eplus_Retrade = "EPLUS_RETRADE"            // UpcomingTrips-Display: Exchange
    case Unknown = "UNKNOWN"
    
    var name: String {
        return self.rawValue
    }
    
    // Helper methods for UI
    public static func fromName(name : String) -> ExchangeTransactionType {
        if ExchangeTransactionType.Regular_Exchange.name == name {
            return ExchangeTransactionType.Regular_Exchange
        } else if ExchangeTransactionType.ShortStay_Exchange.name == name {
            return ExchangeTransactionType.ShortStay_Exchange
        } else if ExchangeTransactionType.Cruise_Exchange.name == name {
            return ExchangeTransactionType.Cruise_Exchange
        } else if ExchangeTransactionType.Hotel_Exchange.name == name {
            return ExchangeTransactionType.Hotel_Exchange
        } else if ExchangeTransactionType.Rental.name == name {
            return ExchangeTransactionType.Rental
        } else if ExchangeTransactionType.Full_Fee_Retrade.name == name {
            return ExchangeTransactionType.Full_Fee_Retrade
        } else if ExchangeTransactionType.Eplus_Retrade.name == name {
            return ExchangeTransactionType.Eplus_Retrade
        } else {
            return ExchangeTransactionType.Unknown
        }
    }
    
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public func isRental() -> Bool {
        return isThis(name: "RENTAL")
    }
    
    public func isRegularExchange() -> Bool {
        return isThis(name: "SHOP")
    }
    
    public func isShortStayExchange() -> Bool {
        return isThis(name: "SHORT_STAY")
    }
    
    public func isCruiseExchange() -> Bool {
        return isThis(name: "CRUISE_EXCHANGE")
    }
    
    public func isHotelExchange() -> Bool {
        return isThis(name: "HOTEL_EXCHANGE")
    }
    
    public func isFullFeeRetrade() -> Bool {
        return isThis(name: "FULL_FEE-RETRADE")
    }
    
    public func isEplusRetrade() -> Bool {
        return isThis(name: "EPLUS_RETRADE")
    }
    
    public func friendlyNameForUpcomingTrip() -> String {
        let name = self.rawValue.lowercased().replacingOccurrences(of: "_", with: " ")
        
        let exchangeTransactionType = ExchangeTransactionType.fromName(name: self.rawValue)
        if (exchangeTransactionType.isRental()) {
            return "Getaway"
        } else if (exchangeTransactionType.isShortStayExchange()) {
            return name.capitalized + " Exchange"
        } else if (exchangeTransactionType.isRegularExchange() || exchangeTransactionType.isEplusRetrade()) {
            return "Exchange"
        }
        return name.capitalized
    }

}
