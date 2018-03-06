//
//  TrackCodeCategory.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 7/13/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum TrackCodeCategory : String {
    case GuaranteedMember = "GUARANTEED_MEMBER"         // weigth = 5
    case GuaranteedPurchase = "GUARANTEED_PURCHASE"     // weigth = 4
    case ReturnableMember = "RETURNABLE_MEMBER"         // weigth = 3
    case ReturnablePurchase = "RETURNABLE_PURCHASE"     // weigth = 2
    case OtherCategory = "OTHER_CATEGORY"               // weigth = 1
    case Unknown = "UNKNOWN"
    
    static let weigthMapper: [TrackCodeCategory: Int] = [
        .GuaranteedMember: 5,
        .GuaranteedPurchase: 4,
        .ReturnableMember: 3,
        .ReturnablePurchase: 2,
        .OtherCategory: 1,
        .Unknown: 0
    ]
    
    public var name: String {
        return self.rawValue
    }
    
    public var weigth: Int {
        return TrackCodeCategory.weigthMapper[self]!
    }
    
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public func isGuaranteedMember() -> Bool {
        return isThis(name: "GUARANTEED_MEMBER")
    }
    
    public func isGuaranteedPurchase() -> Bool {
        return isThis(name: "GUARANTEED_PURCHASE")
    }
    
    public func isReturnableMember() -> Bool {
        return isThis(name: "RETURNABLE_MEMBER")
    }
    
    public func isReturnablePurchase() -> Bool {
        return isThis(name: "RETURNABLE_PURCHASE")
    }
    
    public func isOtherCategory() -> Bool {
        return isThis(name: "OTHER_CATEGORY")
    }
    
    public static func fromName(name : String?) -> TrackCodeCategory {
        if TrackCodeCategory.GuaranteedMember.name == name {
            return TrackCodeCategory.GuaranteedMember
        } else if TrackCodeCategory.GuaranteedPurchase.name == name {
            return TrackCodeCategory.GuaranteedPurchase
        } else if TrackCodeCategory.ReturnableMember.name == name {
            return TrackCodeCategory.ReturnableMember
        } else if TrackCodeCategory.ReturnablePurchase.name == name {
            return TrackCodeCategory.ReturnablePurchase
        } else if TrackCodeCategory.OtherCategory.name == name {
            return TrackCodeCategory.OtherCategory
        } else {
            return TrackCodeCategory.Unknown
        }
    }
    
}

