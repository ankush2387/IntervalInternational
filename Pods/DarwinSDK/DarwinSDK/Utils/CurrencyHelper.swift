//
//  CurrencyHelper.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/17/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

public struct CurrencyHelper {

    //
    // Map of registered currencies by code.
    //
    private var currenciesByCode = [String:Currency]()
    
    public init() {
        // Init the Map of currenciesByCode
        registerCurrencies()
    }

    //
    // Get the Currency for the specified three letter currency code.
    // A currency is uniquely identified by a three letter code, based on ISO-4217.
    // Valid currency codes are three upper-case ASCII letters.
    //
    // param currencyCode the three-letter currency code, not null
    // return the singleton instance, never null
    //
    public func getCurrency(currencyCode: String) -> Currency {
        if let currency = currenciesByCode[currencyCode] {
            return currency
        } else {
            // create a default currency for provided currencyCode
            return Currency(currencyCode.uppercased(), currencyCode.uppercased(), "")
        }
    }
    
    //
    // Get the currency friendly symbol to display in UI
    //
    // param currencyCode
    // param countryCode
    // return the currency friendly symbol
    //
    public func getCurrencyFriendlySymbol(currencyCode: String, countryCode: String) -> String {
        let currency = getCurrency(currencyCode: currencyCode)
        
        switch(currency.code) {
        case "USD":
            let USACANCAR = "US,USA,CAN,AGU,ANT,ARU,BAH,BAR,BER,ISV,BWI,CAY,DCB,WIN,FGU,FWI,GRD,GUP,HAI,JAM,MTQ,MST,AHO,SBT,STL,STV,SKT,STM,TRI,TCI"
            return USACANCAR.contains(countryCode.uppercased()) ? currency.symbol : "US" + currency.symbol
        case "AUD":
            return "AU" + currency.symbol
        case "NZD":
            return "NZ" + currency.symbol
        default:
            return currency.symbol
        }
    }
    
    //
    // Get the currency friendly symbol to display in UI
    //
    // param currencyCode
    // return the currency friendly symbol
    //
    public func getCurrencyFriendlySymbol(currencyCode: String) -> String {
        return getCurrencyFriendlySymbol(currencyCode: currencyCode, countryCode: "")
    }
    
    //
    // Register a new Currency.
    // A currency is uniquely identified by a three letter code, based on ISO-4217.
    // Valid currency codes are three upper-case ASCII letters.
    //
    // param currencyCode the three-letter currency code, not null
    // param currencySymbol the currency symbol
    // param currencyDescription the currency description
    // return the singleton instance, never null
    //
    public mutating func registerCurrency(_ currencyCode: String, _ currencySymbol: String, _ currencyDescription: String) -> Currency {
        let currency = Currency(currencyCode, currencySymbol, currencyDescription)
        currenciesByCode[currencyCode] = currency
        return currency
    }
    
    //
    // Register default Interval currencies.
    //
    mutating fileprivate func registerCurrencies() {
        _ = registerCurrency("VEF", "Bs", "BOLIVAR")
        _ = registerCurrency("ARS", "$", "ARGENTINE PESO")
        _ = registerCurrency("AUD", "$", "AUSTRALIAN DOLLAR")
        _ = registerCurrency("VEB", "Bs", "BOLIVAR")
        _ = registerCurrency("CLP", "$", "CHILEAN PESO")
        _ = registerCurrency("COP", "$", "COLOMBIAN PESO")
        _ = registerCurrency("DKK", "DNK", "DANISH KRONE")
        _ = registerCurrency("EGP", "£", "EGYPTIAN POUND")
        _ = registerCurrency("EUR", "€", "EURO")
        _ = registerCurrency("ILS", "SHEKEL", "ISRAELI SHEKEL")
        _ = registerCurrency("INR", "Rp", "INDIAN RUPEE")
        _ = registerCurrency("MAD", "Dh", "MOROCCAN DIRHAM")
        _ = registerCurrency("NOK", "NOK", "NORWEGIAN KRONE")
        _ = registerCurrency("MXN", "$", "MEXICAN PESO")
        _ = registerCurrency("NZD", "$", "NEW ZEALAND DOLLAR")
        _ = registerCurrency("BRL", "B$", "BRAZILIAN REAL")
        _ = registerCurrency("SEK", "SEK", "SWEDISH KRONA")
        _ = registerCurrency("TND", "Td", "TUNISIAN DINAR")
        _ = registerCurrency("GBP", "£", "POUND STERLING")
        _ = registerCurrency("USD", "$", "US DOLLARS")
        _ = registerCurrency("ZAR", "R", "RAND")
    }
}

// Protocol to hide our implementation of our Singleton.
public protocol CurrencyHelperLocatorProtocol {
    func provideHelper() -> CurrencyHelper
}

// Singleton implementation for the CurrencyHelperLocatorProtocol.
// Use an enum with a single case that implement our protocol.
public enum CurrencyHelperLocator: CurrencyHelperLocatorProtocol {
    case sharedInstance
    
    public func provideHelper() -> CurrencyHelper {
        return CurrencyHelper()
    }
}
