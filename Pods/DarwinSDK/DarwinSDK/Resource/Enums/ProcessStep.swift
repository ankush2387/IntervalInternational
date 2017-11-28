//
//  ProcessStep.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation

public enum ProcessStep : String {
    case Prepare = "PREPARE"
    case Recap = "RECAP"
    case End = "END"
    case Unknown = "UNKNOWN"
    
    var name: String {
        return self.rawValue
    }
    
    public func isThis(name : String) -> Bool {
       return self.name == name
    }
    
    public func isPrepare() -> Bool {
        return isThis(name: "PREPARE")
    }
    
    public func isRecap() -> Bool {
        return isThis(name: "RECAP")
    }

    public func isEnd() -> Bool {
        return isThis(name: "END")
    }
    
    public static func fromName(name : String) -> ProcessStep {
        if ProcessStep.Prepare.name == name {
            return ProcessStep.Prepare
        } else if ProcessStep.Recap.name == name {
            return ProcessStep.Recap
        }else if ProcessStep.End.name == name {
            return ProcessStep.End
        } else {
            return ProcessStep.Unknown
        }
    }
}
