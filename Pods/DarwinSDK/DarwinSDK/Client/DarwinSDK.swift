//
//  DarwinSDK.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/1/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import XCGLogger
import SwiftyJSON

public enum Environment
{
    case development
    case development2
    case omniture
    
    case qa
    case qa2
    case staging
    case production
    
    case qa_dns
    case qa2_dns
    case staging_dns
    case production_dns
}

open class DarwinSDK
{
    open static var logger = XCGLogger()
    
    open static var sharedInstance = DarwinSDK()
    
    var environment = Environment.development
    var clientId : String = ""
    var clientSecret : String = ""

    
    open func config(_ environment:Environment, client:String, secret:String) {
        self.config(environment:environment, client: client, secret: secret, logLevel: .info)
    }
    
    open func config(_ environment:Environment, client:String, secret:String, logger:XCGLogger) {
        DarwinSDK.logger = logger
        self.config(environment:environment, client: client, secret: secret, logLevel: logger.outputLevel)
    }
    
    open func config(environment:Environment, client:String, secret:String, logLevel:XCGLogger.Level) {
        self.environment = environment
        self.clientId = client
        self.clientSecret = secret
        
        DarwinSDK.logger.setup(level: logLevel, showLogIdentifier: true, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLevel: nil)
    }
    
    open func getApiUri(withContextAndVersion:Bool = true) -> String
    {
        if self.environment == .development {
            return ( withContextAndVersion ? "https://dev-mag.ii-apps.com/darwin/v1" : "https://dev-mag.ii-apps.com" )
        } else if self.environment == .development2 {
            return ( withContextAndVersion ? "https://dev2-mag.ii-apps.com/darwin/v1" : "https://dev2-mag.ii-apps.com" )
        } else if self.environment == .qa {
            return ( withContextAndVersion ? "https://qa-mag.ii-apps.com/darwin/v1" : "https://qa-mag.ii-apps.com" )
        } else if self.environment == .qa2 {
            return ( withContextAndVersion ? "https://qa2-mag.ii-apps.com/darwin/v1" : "https://qa2-mag.ii-apps.com" )
        } else if self.environment == .staging {
            return ( withContextAndVersion ? "https://staging-mag.ii-apps.com/darwin/v1" : "https://staging-mag.ii-apps.com" )
        } else if self.environment == .production {
            return ( withContextAndVersion ? "https://mag.ii-apps.com/darwin/v1" : "https://mag.ii-apps.com" )
        } else if self.environment == .qa_dns {
            return ( withContextAndVersion ? "https://qa-api.intervalintl.com/darwin/v1" : "https://qa-api.intervalintl.com" )
        } else if self.environment == .qa2_dns {
            return ( withContextAndVersion ? "https://qa2-api.intervalintl.com/darwin/v1" : "https://qa2-api.intervalintl.com" )
        } else if self.environment == .staging_dns {
            return ( withContextAndVersion ? "https://staging-api.intervalintl.com/darwin/v1" : "https://staging-api.intervalintl.com" )
        }  else if self.environment == .production_dns {
            return ( withContextAndVersion ? "https://api.intervalintl.com/darwin/v1" : "https://api.intervalintl.com" )
        } else {
            // production_dns as default
            return ( withContextAndVersion ? "https://api.intervalintl.com/darwin/v1" : "https://api.intervalintl.com" )
        }
    }
    
    open func getTokenizeApiUri(withContextAndVersion:Bool = true) -> String
    {
        if self.environment == .development {
            return ( withContextAndVersion ? "https://dev-mag.ii-apps.com/tokenize/v1" : "https://dev-mag.ii-apps.com" )
        }
        if self.environment == .development2 {
            return ( withContextAndVersion ? "https://dev2-mag.ii-apps.com/tokenize/v1" : "https://dev2-mag.ii-apps.com" )
        }
        else if self.environment == .qa {
            return ( withContextAndVersion ? "https://qa-mag.ii-apps.com/tokenize/v1" : "https://qa-mag.ii-apps.com" )
        }
        else if self.environment == .qa2 {
            return ( withContextAndVersion ? "https://qa2-mag.ii-apps.com/tokenize/v1" : "https://qa2-mag.ii-apps.com" )
        }
        else {
            return ( withContextAndVersion ? "https://mag.ii-apps.com/tokenize/v1" : "https://mag.ii-apps.com" )
        }
    }
    
    open func getLegacyApiUri() -> String
    {
        if self.environment == .development {
            return "https://www.intervalworld.com/web/app"
        }
        else if self.environment == .qa {
            return "https://www.intervalworld.com/web/app"
        }
        else {
            return "https://www.intervalworld.com/web/app"
        }
    }

    open static func parseDarwinError(statusCode:Int, json:JSON) -> NSError {
        var errorCode: String?
        var errorDesc: String?
        
        // Handle API errors
        errorCode = json["error"].string
        errorDesc = json["error_description"].string
        
        // Handle API Process errors (has a different payload => { "id": 799, "step": "END", "errors": [ { "code": "WEB0065", "description": "We're sorry, this unit is no longer available." } ] }
        if (errorCode == nil && errorDesc == nil && json["errors"].exists()) {
            let firstError = json["errors"].arrayValue.first
            errorCode = firstError?["code"].string
            errorDesc = firstError?["description"].string
        }
        
        // Handle others errors or define as Unknown
        if (errorCode == nil && errorDesc == nil) {
            errorCode = json["code"].string ?? "unknown_error"
            errorDesc = json["description"].string ?? "Unknown error: \(statusCode)."
        }
        
        let userInfo: [String:Any] = [
            NSLocalizedDescriptionKey : errorDesc!,
            "errorCode": errorCode!
        ]
      
        let error = NSError(domain: "com.intervalintl.darwin", code: statusCode, userInfo: userInfo)
        
        DarwinSDK.logger.error("\(errorCode!): \(error.localizedDescription)")
        return error
    }
    
    open static func parseDarwinAuthError(statusCode:Int, json:JSON) -> NSError {
        // {"error": "access_denied", "error_description": "Access Denied", "accountLocked": false, "loginAttemps": 2}
        var errorCode: String?
        var errorDesc: String?
        var accountLocked: Bool?
        var loginAttemps: Int?
        
        // Handle Auth errors
        errorCode = json["error"].string
        errorDesc = json["error_description"].string
        accountLocked = json["accountLocked"].boolValue
        loginAttemps = json["loginAttemps"].intValue
        
        // Handle Unknown errors
        if (errorCode == nil && errorDesc == nil) {
            errorCode = json["code"].string ?? "unknown_error"
            errorDesc = json["description"].string ?? "Unknown error: \(statusCode)."
        }
        
        var userInfo: [String:Any] = [
            NSLocalizedDescriptionKey : errorDesc!,
            "errorCode": errorCode!
        ]
        
        if (accountLocked != nil) {
            userInfo["accountLocked"] = accountLocked!
        }
        
        if (loginAttemps != nil) {
            userInfo["loginAttemps"] = loginAttemps!
        }
      
        let error = NSError(domain: "com.intervalintl.darwin", code: statusCode, userInfo: userInfo)
        
        DarwinSDK.logger.error("\(errorCode!): \(error.localizedDescription)")
        return error
    }

    open static func parseDarwinError(_ response:String) -> NSError {
        let error = NSError(domain: "com.intervalintl.darwin", code: 400, userInfo: ["message" : "I know, Right."] )
        return error
    }
    
}
