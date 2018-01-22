//
//  KitchenType.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 8/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation

public enum KitchenType : String {
    case NO_KITCHEN = "NO_KITCHEN"
    case LIMITED_KITCHEN = "LIMITED_KITCHEN"
    case FULL_KITCHEN = "FULL_KITCHEN"
    
    var name: String {
        return self.rawValue
    }
    
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    // Helper methods for UI
    public static func fromName(name : String) -> KitchenType {
        if KitchenType.NO_KITCHEN.name == name {
            return KitchenType.NO_KITCHEN
        } else if KitchenType.LIMITED_KITCHEN.name == name {
            return KitchenType.LIMITED_KITCHEN
        }else if KitchenType.FULL_KITCHEN.name == name {
            return KitchenType.FULL_KITCHEN
        } else {
            // Fallback
            return KitchenType.NO_KITCHEN
        }
    }
    
    public func friendlyName() -> String {
        let name = self.rawValue.lowercased().replacingOccurrences(of: "_", with: " ")
        return name.capitalized
    }
    
    public static let forDisplay = [ NO_KITCHEN, LIMITED_KITCHEN, FULL_KITCHEN ]
    
    public static func fromFriendlyName(_ friendlyName:String) -> KitchenType? {
        let name = friendlyName.uppercased().replacingOccurrences(of: " ", with: "_")
        return KitchenType(rawValue: name)
    }
}
