//
//  VirtualWeekAction.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/12/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

public enum VirtualWeekAction : String {
    case SUPPRESS_VIRTUAL_DATES = "SUPPRESS_VIRTUAL_DATES"
    case SUPPRESS_VIRTUAL_WEEK = "SUPPRESS_VIRTUAL_WEEK"
    case ALLOW_VIRTUAL_DEPOSIT_AFTER_MEMBER_EXPIRATION = "ALLOW_VIRTUAL_DEPOSIT_AFTER_MEMBER_EXPIRATION"
    case UNKNOWN = "UNKNOWN"
    
    var name: String {
        return self.rawValue
    }
    
    // Helper methods for UI
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public static func fromName(name : String) -> VirtualWeekAction {
        if VirtualWeekAction.SUPPRESS_VIRTUAL_DATES.name == name {
            return VirtualWeekAction.SUPPRESS_VIRTUAL_DATES
        } else if VirtualWeekAction.SUPPRESS_VIRTUAL_WEEK.name == name {
            return VirtualWeekAction.SUPPRESS_VIRTUAL_WEEK
        } else if VirtualWeekAction.ALLOW_VIRTUAL_DEPOSIT_AFTER_MEMBER_EXPIRATION.name == name {
            return VirtualWeekAction.ALLOW_VIRTUAL_DEPOSIT_AFTER_MEMBER_EXPIRATION
        } else {
            return VirtualWeekAction.UNKNOWN
        }
    }
}
