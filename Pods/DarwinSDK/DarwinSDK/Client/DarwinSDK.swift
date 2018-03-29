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

public enum Environment {
    case development
    case development2
    case omniture
    case qa1
    case qa2
    case staging
    case production
    case qa1_dns
    case qa2_dns
    case staging_dns
    case production_dns
}

open class DarwinSDK {
    open static var logger = XCGLogger()
    open static var sharedInstance = DarwinSDK()
    
    var environment = Environment.development2
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
        
        DarwinSDK.logger.setup(level: logLevel, showLogIdentifier: true, showFunctionName: true,
                               showThreadName: true, showLevel: true, showFileNames: true,
                               showLineNumbers: true, showDate: true, writeToFile: nil, fileLevel: nil)
    }
    
    open func getApiUri(withContextAndVersion:Bool = true) -> String {
        switch self.environment {
        case .development:
            return withContextAndVersion ? "https://dev-mag.ii-apps.com/darwin/v1" : "https://dev-mag.ii-apps.com"
        case .development2:
            return withContextAndVersion ? "https://dev2-mag.ii-apps.com/darwin/v1" : "https://dev2-mag.ii-apps.com"
        case .qa1:
            return withContextAndVersion ? "https://qa1-mag.ii-apps.com/darwin/v1" : "https://qa1-mag.ii-apps.com"
        case .qa2:
            return withContextAndVersion ? "https://qa2-mag.ii-apps.com/darwin/v1" : "https://qa2-mag.ii-apps.com"
        case .staging:
            return withContextAndVersion ? "https://staging-mag.ii-apps.com/darwin/v1" : "https://staging-mag.ii-apps.com"
        case .production:
            return withContextAndVersion ? "https://mag.ii-apps.com/darwin/v1" : "https://mag.ii-apps.com"
        case .qa1_dns:
            return withContextAndVersion ? "https://qa1-api.intervalintl.com/darwin/v1" : "https://qa1-api.intervalintl.com"
        case .qa2_dns:
            return withContextAndVersion ? "https://qa2-api.intervalintl.com/darwin/v1" : "https://qa2-api.intervalintl.com"
        case .staging_dns:
            return withContextAndVersion ? "https://staging-api.intervalintl.com/darwin/v1" : "https://staging-api.intervalintl.com"
        case .production_dns:
            return withContextAndVersion ? "https://api.intervalintl.com/darwin/v1" : "https://api.intervalintl.com"
        default:
            return withContextAndVersion ? "https://api.intervalintl.com/darwin/v1" : "https://api.intervalintl.com"
        }
    }
    
    open func getTokenizeApiUri(withContextAndVersion:Bool = true) -> String {
        switch self.environment {
        case .development:
            return withContextAndVersion ? "https://dev-mag.ii-apps.com/tokenize/v1" : "https://dev-mag.ii-apps.com"
        case .development2:
            return withContextAndVersion ? "https://dev2-mag.ii-apps.com/tokenize/v1" : "https://dev2-mag.ii-apps.com"
        case .qa1:
            return withContextAndVersion ? "https://qa1-mag.ii-apps.com/tokenize/v1" : "https://qa1-mag.ii-apps.com"
        case .qa2:
            return withContextAndVersion ? "https://qa2-mag.ii-apps.com/tokenize/v1" : "https://qa2-mag.ii-apps.com"
        case .staging:
            return withContextAndVersion ? "https://staging-mag.ii-apps.com/tokenize/v1" : "https://staging-mag.ii-apps.com"
        case .production:
            return withContextAndVersion ? "https://mag.ii-apps.com/tokenize/v1" : "https://mag.ii-apps.com"
        case .qa1_dns:
            return withContextAndVersion ? "https://qa1-api.intervalintl.com/tokenize/v1" : "https://qa1-api.intervalintl.com"
        case .qa2_dns:
            return withContextAndVersion ? "https://qa2-api.intervalintl.com/tokenize/v1" : "https://qa2-api.intervalintl.com"
        case .staging_dns:
            return withContextAndVersion ? "https://staging-api.intervalintl.com/tokenize/v1" : "https://staging-api.intervalintl.com"
        case .production_dns:
            return withContextAndVersion ? "https://api.intervalintl.com/tokenize/v1" : "https://api.intervalintl.com"
        default:
            return withContextAndVersion ? "https://api.intervalintl.com/tokenize/v1" : "https://api.intervalintl.com"
        }
    }
    
    open static func parseDarwinError(statusCode:Int, json:JSON) -> NSError {
        let friendlyErrorMsg = "We’re sorry, we are unable to process your request at this time. Please contact your local servicing office for assistance."
        
        var userInfo: [String:Any] = [
            NSLocalizedDescriptionKey: friendlyErrorMsg as Any,
            "apiErrorCode": "" as Any,
            "apiErrorDescription": "" as Any,
            "correlationId": "" as Any
        ]
        
        if let errorCode = json["error"].string {
            userInfo["apiErrorCode"] = errorCode as Any
        } else if let errorCode = json["code"].string {
            userInfo["apiErrorCode"] = errorCode as Any
        }
        if let errorDesc = json["error_description"].string {
            userInfo[NSLocalizedDescriptionKey] = errorDesc as Any
            userInfo["apiErrorDescription"] = errorDesc as Any
        } else if let errorDesc = json["description"].string {
            userInfo[NSLocalizedDescriptionKey] = errorDesc as Any
            userInfo["apiErrorDescription"] = errorDesc as Any
        }
        if let _ = json["support"].dictionary, let _ = json["support"]["cause"].dictionary,
            let correlationId = json["support"]["cause"]["correlationId"].string {
            userInfo["correlationId"] = correlationId as Any
        }
        
        // Process errors have a different payload =>
        // [ {"code" : "ERRORDAO", "description" : "The homeKitchenType property must not be null."} ]
        if let errorsArray = json.array, let error:JSON = errorsArray.first {
            if let errorCode = error["code"].string {
                userInfo["apiErrorCode"] = errorCode as Any
            }
            if let errorDesc = error["description"].string {
                userInfo[NSLocalizedDescriptionKey] = errorDesc as Any
                userInfo["apiErrorDescription"] = errorDesc as Any
            }
            if let _ = error["support"].dictionary, let _ = error["support"]["cause"].dictionary,
                let correlationId = error["support"]["cause"]["correlationId"].string {
                userInfo["correlationId"] = correlationId as Any
            }
        }
        
        // Process errors have a different payload =>
        // { "id": 799, "step": "END", "errors": [ { "code": "WEB0065", "description": "We're sorry, this unit is no longer available." } ] }
        if let errorsArray = json["errors"].array, let error:JSON = errorsArray.first  {
            if let errorCode = error["code"].string {
                userInfo["apiErrorCode"] = errorCode as Any
            }
            if let errorDesc = error["description"].string {
                userInfo[NSLocalizedDescriptionKey] = errorDesc as Any
                userInfo["apiErrorDescription"] = errorDesc as Any
            }
            if let _ = error["support"].dictionary, let _ = error["support"]["cause"].dictionary,
                let correlationId = error["support"]["cause"]["correlationId"].string {
                userInfo["correlationId"] = correlationId as Any
            }
        }
        
        let error = NSError(domain: "com.intervalintl.darwin", code: statusCode, userInfo: userInfo)
        DarwinSDK.logger.error("\(error.code): \(error.description)")
        return error
    }
    
    open static func parseDarwinAuthError(statusCode:Int, json:JSON) -> NSError {
        let friendlyGeneralErrorMsg = "We’re sorry, we are unable to log you in at this time. Please contact your local servicing office for assistance."
        let friendlyAccountLockedErrorMsg = "Your account has been locked. Select from the Help menu for further assistance."
        
        var userInfo: [String:Any] = [
            NSLocalizedDescriptionKey: friendlyGeneralErrorMsg as Any,
            "apiErrorCode": "" as Any,
            "apiErrorDescription": "" as Any,
            "loginAttempts": 1 as Any,
            "lockedReasons": "" as Any,
            "correlationId": "" as Any
        ]
        
        if let errorCode = json["error"].string {
            userInfo["apiErrorCode"] = errorCode as Any
        }
        if let errorDesc = json["error_description"].string {
            userInfo["apiErrorDescription"] = errorDesc as Any
        }
        if let loginAttempts = json["loginAttempts"].int {
            userInfo["loginAttempts"] = loginAttempts
        }
        if let lockedReasons = json["reasons"].array {
            let reasons = lockedReasons.map { $0.string! }
            userInfo["lockedReasons"] = reasons
            
            // Overwrite the code based in Reasons
            if !reasons.isEmpty {
                userInfo["apiErrorCode"] = reasons[0] as Any
                
                // Overwrite the description based in Reasons if contains the value ACCOUNT_LOCKED
                if reasons.contains("ACCOUNT_LOCKED") {
                    userInfo[NSLocalizedDescriptionKey] = friendlyAccountLockedErrorMsg as Any
                }
            }
        }
        if let _ = json["support"].dictionary, let _ = json["support"]["cause"].dictionary,
            let correlationId = json["support"]["cause"]["correlationId"].string {
            userInfo["correlationId"] = correlationId as Any
        }
        
        let error = NSError(domain: "com.intervalintl.DarwinSDK", code: statusCode, userInfo: userInfo)
        DarwinSDK.logger.error("\(error.code): \(error.description)")
        return error
    }
}

