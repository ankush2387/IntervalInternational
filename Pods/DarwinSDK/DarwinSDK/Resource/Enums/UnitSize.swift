//
//  UnitSize.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 8/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation

public enum UnitSize : String {
    case Studio = "STUDIO"
    case OneBedroom = "ONE_BEDROOM"
    case TwoBedroom = "TWO_BEDROOM"
    case ThreeBedroom = "THREE_BEDROOM"
    case FourBedroom = "FOUR_BEDROOM"
    case Unknown = "UNKNOWN"
    
    // Helper methods for UI
    public func friendlyName() -> String {
        let name = self.rawValue.lowercased().replacingOccurrences(of: "_", with: " ")
        return name.capitalized
    }
    
    public static let forDisplay = [ Studio, OneBedroom, TwoBedroom, ThreeBedroom, FourBedroom ]
  
    public static func fromFriendlyName(_ friendlyName:String) -> UnitSize? {
        let name = friendlyName.uppercased().replacingOccurrences(of: " ", with: "_")
        return UnitSize(rawValue: name)
    }
    
}
