//
//  Config.swift
//  IntervalApp
//
//  Created by Ralph Fiol on 1/12/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import XCGLogger
import DarwinSDK

//
// Property List Keys
//
enum PlistKey: String {
    case DarwinClientKey    = "DarwinClientKey"
    case DarwinSecretKey    = "DarwinSecret"
    case LogLevel           = "LogLevel"
    case Environment        = "Environment"
    case BrightcoveAccountId = "BrightcoveAccountId"
    case BrightcovePolicyKey = "BrightcovePolicyKey"
}

//
// Config
// Provides methods to make it easier to read the Info.plist file.
// You must define a dictionary keyed by "IntervalConfig".
//
class Config {
    static var sharedInstance = Config()
    var interval: [String: AnyObject]
    
    init() {
        
        self.interval = [ "": "" as AnyObject ]
        
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let plist = (NSDictionary(contentsOfFile: path) as? [String: AnyObject]) {
                self.interval = plist["IntervalConfig"] as! [String: AnyObject]
            }
        }
    }
    
    func get(_ key: PlistKey) -> String! {
        return self.get(key, defaultValue: "")
    }
    
    func get(_ key: PlistKey, defaultValue: String) -> String! {
        
        if let value = self.interval[key.rawValue] {
            return value as! String
        } else {
            return defaultValue
        }
    }
    
    func getEnvironment() -> Environment {
        let envStr = self.get(.Environment, defaultValue: "info").lowercased()
        
        switch envStr {
        case "dev", "development":
            return Environment.development
            
        case "dev2", "development2":
            return Environment.development2
            
        case "omniture":
            return Environment.omniture
            
        case "qa":
            return Environment.qa
            
        case "qa2":
            return Environment.qa2
            
        case "staging":
            return Environment.staging
            
        case "prod", "production":
            return Environment.production
            
        case "qa_dns":
            return Environment.qa_dns
            
        case "qa2_dns":
            return Environment.qa2_dns
            
        case "staging_dns":
            return Environment.staging_dns
            
        case "prod_dns", "production_dns":
            return Environment.production_dns

        default:
            return Environment.production_dns
        }
    }
    
    func getLogLevel() -> XCGLogger.Level {
        let logLevelStr = self.get(.LogLevel, defaultValue: "info").lowercased()
        
        switch logLevelStr {
        case "debug":
            return XCGLogger.Level.debug
            
        case "warning", "warn":
            return XCGLogger.Level.warning
            
        case "error":
            return XCGLogger.Level.error
            
        case "none":
            return XCGLogger.Level.none
            
        case "verbose":
            return XCGLogger.Level.verbose
            
        case "severe":
            return XCGLogger.Level.severe
            
        default:
            return XCGLogger.Level.info
        }
    }
}
