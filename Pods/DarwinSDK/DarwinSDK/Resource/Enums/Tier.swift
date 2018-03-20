//
//  Tier.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 8/17/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum Tier : String {
    case PreferedResidence = "preferedresidence"        // weigth = 9
    case Premier = "premier"                            // weigth = 8
    case PremierBoutique = "premierboutique"            // weigth = 7
    case Elite = "elite"                                // weigth = 6
    case EliteBoutique = "eliteboutique"                // weigth = 5
    case Select = "select"                              // weigth = 4
    case SelectBoutique = "selectboutique"              // weigth = 3
    case Affiliate = "affiliate"                        // weigth = 2
    case Unknown = "unknown"                            // weigth = 1
    
    static let weigthMapper: [Tier: Int] = [
        .PreferedResidence: 7,
        .Premier: 6,
        .PremierBoutique: 5,
        .Elite: 4,
        .EliteBoutique: 3,
        .Select: 2,
        .SelectBoutique: 1,
        .Affiliate: 0,
        .Unknown: -1
    ]
    
    public var name: String {
        return self.rawValue
    }
    
    public var weigth: Int {
        return Tier.weigthMapper[self]!
    }
    
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public func isPreferedResidence() -> Bool {
        return isThis(name: "preferedresidence")
    }
    
    public func isPremier() -> Bool {
        return isThis(name: "premier")
    }
    
    public func isPremierBoutique() -> Bool {
        return isThis(name: "premierboutique")
    }
    
    public func isElite() -> Bool {
        return isThis(name: "elite")
    }
    
    public func isEliteBoutique() -> Bool {
        return isThis(name: "eliteboutique")
    }
    
    public func isSelect() -> Bool {
        return isThis(name: "select")
    }
    
    public func isSelectBoutique() -> Bool {
        return isThis(name: "selectboutique")
    }
    
    public func isAffiliate() -> Bool {
        return isThis(name: "affiliate")
    }
    
    public func isUnknown() -> Bool {
        return isThis(name: "unknown")
    }
    
    public static func fromName(name : String?) -> Tier {
        if let thatName = name {
            if Tier.PreferedResidence.name == thatName {
                return Tier.PreferedResidence
            } else if Tier.Premier.name == thatName {
                return Tier.Premier
            } else if Tier.PremierBoutique.name == thatName {
                return Tier.PremierBoutique
            } else if Tier.Elite.name == thatName {
                return Tier.Elite
            } else if Tier.EliteBoutique.name == thatName {
                return Tier.EliteBoutique
            } else if Tier.Select.name == thatName {
                return Tier.Select
            } else if Tier.SelectBoutique.name == thatName {
                return Tier.SelectBoutique
            } else if Tier.Affiliate.name == thatName {
                return Tier.Affiliate
            }
        }
        return Tier.Unknown
    }
    
}

