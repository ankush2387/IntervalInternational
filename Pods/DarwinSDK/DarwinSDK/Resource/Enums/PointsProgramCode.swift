//
//  PointProgramCode.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/12/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

public enum PointsProgramCode : String {
    case CIG = "CIG"
    case ITW = "ITW"
    case SVC = "SVC"
    case UNKNOWN = "UNKNOWN"
    
    var name: String {
        return self.rawValue
    }
    
    // Helper methods for UI
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public func isCIG() -> Bool {
        return isThis(name: "CIG")
    }
    
    public func isITW() -> Bool {
        return isThis(name: "ITW")
    }
    
    public func isSVC() -> Bool {
        return isThis(name: "SVC")
    }
    
    public static func fromName(name : String) -> PointsProgramCode {
        if PointsProgramCode.CIG.name == name {
            return PointsProgramCode.CIG
        } else if PointsProgramCode.ITW.name == name {
            return PointsProgramCode.ITW
        } else if PointsProgramCode.SVC.name == name {
            return PointsProgramCode.SVC
        } else {
            return PointsProgramCode.UNKNOWN
        }
    }
}
