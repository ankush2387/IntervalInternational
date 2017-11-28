//
//  AvailabilitySortType.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 7/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum AvailabilitySortType : String {
    case Default = "DEFAULT"
    case ResortNameAsc = "RESORT_NAME_ASC"
    case ResortNameDesc = "RESORT_NAME_DESC"
    case CityNameAsc = "CITY_NAME_ASC"
    case CityNameDesc = "CITY_NAME_DESC"
    case ResortTierLowToHigh = "RESORT_TIER_LOW_TO_HIGH"
    case ResortTierHighToLow = "RESORT_TIER_HIGH_TO_LOW"
    case PriceLowToHigh = "PRICE_LOW_TO_HIGH"
    case PriceHighToLow = "PRICE_HIGH_TO_LOW"
    case Unknown = "UNKNOWN"
    
    var name: String {
        return self.rawValue
    }
    
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public func isDefault() -> Bool {
        return isThis(name: "DEFAULT")
    }
    
    public func isResortNameAsc() -> Bool {
        return isThis(name: "RESORT_NAME_ASC")
    }
    
    public func isResortNameDesc() -> Bool {
        return isThis(name: "RESORT_NAME_DESC")
    }
    
    public func isCityNameAsc() -> Bool {
        return isThis(name: "CITY_NAME_ASC")
    }
    
    public func isCityNameDesc() -> Bool {
        return isThis(name: "CITY_NAME_DESC")
    }

    public func isResortTierLowToHigh() -> Bool {
        return isThis(name: "RESORT_TIER_LOW_TO_HIGH")
    }
    
    public func isResortTierHighToLow() -> Bool {
        return isThis(name: "RESORT_TIER_HIGH_TO_LOW")
    }
    
    public func isPriceLowToHigh() -> Bool {
        return isThis(name: "PRICE_LOW_TO_HIGH")
    }
    
    public func isPriceHighToLow() -> Bool {
        return isThis(name: "PRICE_HIGH_TO_LOW")
    }
    
    public static func fromName(name : String) -> AvailabilitySortType {
        if AvailabilitySortType.Default.name == name {
            return AvailabilitySortType.Default
        } else if AvailabilitySortType.ResortNameAsc.name == name {
            return AvailabilitySortType.ResortNameAsc
        } else if AvailabilitySortType.ResortNameDesc.name == name {
            return AvailabilitySortType.ResortNameDesc
        } else if AvailabilitySortType.CityNameAsc.name == name {
            return AvailabilitySortType.CityNameAsc
        } else if AvailabilitySortType.CityNameDesc.name == name {
            return AvailabilitySortType.CityNameDesc
        } else if AvailabilitySortType.ResortTierLowToHigh.name == name {
            return AvailabilitySortType.ResortTierLowToHigh
        } else if AvailabilitySortType.ResortTierHighToLow.name == name {
            return AvailabilitySortType.ResortTierHighToLow
        } else if AvailabilitySortType.PriceLowToHigh.name == name {
            return AvailabilitySortType.PriceLowToHigh
        } else if AvailabilitySortType.PriceHighToLow.name == name {
            return AvailabilitySortType.PriceHighToLow
        } else {
            return AvailabilitySortType.Unknown
        }
    }
}
