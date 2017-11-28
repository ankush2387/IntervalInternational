//
//  KitchenType.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 8/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation

public enum KitchenType : String {
    case NoKitchen = "NO_KITCHEN"
    case LimitedKitchen = "LIMITED_KITCHEN"
    case FullKitchen = "FULL_KITCHEN"
    case Unknown = "UNKNOWN"
    
    // Helper methods for UI
    public func friendlyName() -> String {
        let name = self.rawValue.lowercased().replacingOccurrences(of: "_", with: " ")
        return name.capitalized
    }
    
    public static let forDisplay = [ NoKitchen, LimitedKitchen, FullKitchen ]
  
    public static func fromFriendlyName(_ friendlyName:String) -> UnitSize? {
        let name = friendlyName.uppercased().replacingOccurrences(of: " ", with: "_")
        return UnitSize(rawValue: name)
    }
}
