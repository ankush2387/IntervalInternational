//
//  UnitSize.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 8/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation

public enum UnitSize : String {
    case STUDIO = "STUDIO"
    case ONE_BEDROOM = "ONE_BEDROOM"
    case TWO_BEDROOM = "TWO_BEDROOM"
    case THREE_BEDROOM = "THREE_BEDROOM"
    case FOUR_BEDROOM = "FOUR_BEDROOM"
    case FLOATING_UNIT = "FLOATING_UNIT"
    case UNKNOWN_UNIT = "UNKNOWN_UNIT"
    
    var name: String {
        return self.rawValue
    }
    
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    // Helper methods for UI
    public static func fromName(name : String?) -> UnitSize {
        if UnitSize.STUDIO.name == name {
            return UnitSize.STUDIO
        } else if UnitSize.ONE_BEDROOM.name == name {
            return UnitSize.ONE_BEDROOM
        } else if UnitSize.TWO_BEDROOM.name == name {
            return UnitSize.TWO_BEDROOM
        } else if UnitSize.THREE_BEDROOM.name == name {
            return UnitSize.THREE_BEDROOM
        } else if UnitSize.FOUR_BEDROOM.name == name {
            return UnitSize.FOUR_BEDROOM
        } else if UnitSize.FLOATING_UNIT.name == name {
            return UnitSize.FLOATING_UNIT
        } else if UnitSize.UNKNOWN_UNIT.name == name {
            return UnitSize.UNKNOWN_UNIT
        } else {
            // Fallback
            return UnitSize.UNKNOWN_UNIT
        }
    }
    
    public static let forDisplay = [ STUDIO, ONE_BEDROOM, TWO_BEDROOM, THREE_BEDROOM, FOUR_BEDROOM ]
    
    public func friendlyName() -> String {
        let name = self.rawValue.lowercased().replacingOccurrences(of: "_", with: " ")
        return name.capitalized
    }

    public static func fromFriendlyName(_ friendlyName:String) -> UnitSize? {
        let name = friendlyName.uppercased().replacingOccurrences(of: " ", with: "_")
        return UnitSize(rawValue: name)
    }
    
}
