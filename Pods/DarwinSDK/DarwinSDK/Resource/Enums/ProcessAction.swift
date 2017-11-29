//
//  ProcessAction.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/6/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum ProcessAction : String {
    case Continue = "continue"
    case Back = "back"
    case Recalculate = "recalculate"
    case ProcessPromotionCode = "process-promotion-code"
    case ChangeCurrency = "change-currency"
    case Unknown = "unknown"
    
    var name: String {
        return self.rawValue
    }
    
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public func isContinue() -> Bool {
        return isThis(name: "continue")
    }
    
    public func isBack() -> Bool {
        return isThis(name: "back")
    }
    
    public func isRecalculate() -> Bool {
        return isThis(name: "recalculate")
    }
    
    public func isProcessPromotionCode() -> Bool {
        return isThis(name: "process-promotion-code")
    }
    
    public func isChangeCurrency() -> Bool {
        return isThis(name: "change-currency")
    }
    
    public static func fromName(name : String) -> ProcessAction {
        if ProcessAction.Continue.name == name {
            return ProcessAction.Continue
        } else if ProcessAction.Back.name == name {
            return ProcessAction.Back
        } else if ProcessAction.Recalculate.name == name {
            return ProcessAction.Recalculate
        } else if ProcessAction.ProcessPromotionCode.name == name {
            return ProcessAction.ProcessPromotionCode
        } else if ProcessAction.ChangeCurrency.name == name {
            return ProcessAction.ChangeCurrency
        } else {
            return ProcessAction.Unknown
        }
    }

}
