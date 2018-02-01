//
//  RequestType.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/12/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

public enum RequestType : String {
    case EXCHANGE_PLUS = "EXCHANGE_PLUS"
    case REQUEST_FIRST = "REQUEST_FIRST"
    case DEPOSIT_FIRST = "DEPOSIT_FIRST"
    case LATE_DEPOSIT = "LATE_DEPOSIT"
    case SHORT_NOTICE = "SHORT_NOTICE"
    case MARRIOTT_AFTER = "MARRIOTT_AFTER"
    case MARRIOTT_BEFORE = "MARRIOTT_BEFORE"
    case EXCHANGE_PLUS_DEPOSIT_FIRST = "EXCHANGE_PLUS_DEPOSIT_FIRST"
    case EXCHANGE_PLUS_LATE_DEPOSIT = "EXCHANGE_PLUS_LATE_DEPOSIT"
    case EXCHANGE_PLUS_SHORT_NOTICE = "EXCHANGE_PLUS_SHORT_NOTICE"
    case UNKNOWN = "UNKNOWN"

    var name: String {
        return self.rawValue
    }

    public func friendlyName() -> String {
        let name = self.rawValue.lowercased().replacingOccurrences(of: "_", with: " ")
        return name.capitalized
    }
    
    // Helper methods for UI
    public func isThis(name : String) -> Bool {
        return self.name == name
    }

    public static func fromName(name : String) -> RequestType {
        if RequestType.EXCHANGE_PLUS.name == name {
            return RequestType.EXCHANGE_PLUS
        } else if RequestType.REQUEST_FIRST.name == name {
            return RequestType.REQUEST_FIRST
        } else if RequestType.DEPOSIT_FIRST.name == name {
            return RequestType.DEPOSIT_FIRST
        } else if RequestType.LATE_DEPOSIT.name == name {
            return RequestType.LATE_DEPOSIT
        } else if RequestType.SHORT_NOTICE.name == name {
            return RequestType.SHORT_NOTICE
        } else if RequestType.MARRIOTT_AFTER.name == name {
            return RequestType.MARRIOTT_AFTER
        } else if RequestType.MARRIOTT_BEFORE.name == name {
            return RequestType.MARRIOTT_BEFORE
        } else if RequestType.EXCHANGE_PLUS_DEPOSIT_FIRST.name == name {
            return RequestType.EXCHANGE_PLUS_DEPOSIT_FIRST
        } else if RequestType.EXCHANGE_PLUS_LATE_DEPOSIT.name == name {
            return RequestType.EXCHANGE_PLUS_LATE_DEPOSIT
        } else if RequestType.EXCHANGE_PLUS_SHORT_NOTICE.name == name {
            return RequestType.EXCHANGE_PLUS_SHORT_NOTICE
        } else {
            return RequestType.UNKNOWN
        }
    }
    
    public static func fromFriendlyName(_ friendlyName:String) -> RequestType? {
        let name = friendlyName.uppercased().replacingOccurrences(of: " ", with: "_")
        return RequestType(rawValue: name)
    }
}
