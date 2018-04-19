//
//  BillingEntity.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 4/19/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

//TODO(Frank): Enums should looks like to this one.
public enum BillingEntity : String {
    case Corporate = "CORP"
    case NonCorporate = "NONCORP"

    var name: String {
        return self.rawValue
    }
    
    var isCorporate: Bool {
        return self == BillingEntity.Corporate
    }
    
    var isNonCorporate: Bool {
        return self == BillingEntity.NonCorporate
    }
    
    public static func fromName(name : String) -> BillingEntity? {
        return BillingEntity(rawValue: name)
    }

}
