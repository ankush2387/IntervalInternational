//
//  ActiveChoise.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 7/5/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum ActiveChoise : String {
    case Required = "RequiredChoise"
    case RequitedLite = "RequiredChoiseLite"
    case NoRequired = "NoRequiredChoise"
    case Unknown = "unknown"
    
    var name: String {
        return self.rawValue
    }
    
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public func isRequired() -> Bool {
        return isThis(name: "RequiredChoise")
    }
    
    public func isRequiredLite() -> Bool {
        return isThis(name: "RequiredChoiseLite")
    }
    
    public func isNoRequired() -> Bool {
        return isThis(name: "NoRequiredChoise")
    }
    
    public static func fromName(name : String) -> ActiveChoise {
        if ActiveChoise.Required.name == name {
            return ActiveChoise.Required
        } else if ActiveChoise.RequitedLite.name == name {
            return ActiveChoise.RequitedLite
        } else if ActiveChoise.NoRequired.name == name {
            return ActiveChoise.NoRequired
        } else {
            return ActiveChoise.Unknown
        }
    }
    
}
