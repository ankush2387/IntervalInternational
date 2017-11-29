//
//  AuthProviderClient.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/2/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class AuthProviderClient {
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: POST /access-token
    // Get an User access token.
    // Use this resource to get an access token for a given contact, using an application username and password.  
    // A token returned by this resource will allow the application to act on behalf of a member.
    //
    open static func getAccessToken(_ username: String, password: String, role: String! = "ROLE_USER+ROLE_PRELOGIN+ROLE_TOKENIZE", onSuccess: @escaping(_ accessToken:DarwinAccessToken) -> Void, onError: @escaping(_ error:NSError) -> Void) {
        let params : [String: AnyObject] = [
            "client_id" : DarwinSDK.sharedInstance.clientId as AnyObject,
            "client_secret" : DarwinSDK.sharedInstance.clientSecret as AnyObject,
            "grant_type" : "password" as AnyObject,
            "username" : username as AnyObject,
            "password" : password as AnyObject,
            "scope" : role as AnyObject
        ]
        
        self.getAccessTokenImpl(params, onSuccess: onSuccess, onError: onError)
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: POST /access-token
    // Get a Client/System access token.
    // Use this resource to get a generic access token for the applicaton.  
    // A token returned by this resource will allow the application to make limited service calls, such as "lookup" services, and other non-member requets.
    //
    open static func getClientAccessToken(_ onSuccess: @escaping(_ accessToken: DarwinAccessToken) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let params : [String: AnyObject] = [
            "client_id" : DarwinSDK.sharedInstance.clientId as AnyObject,
            "client_secret" : DarwinSDK.sharedInstance.clientSecret as AnyObject,
            "grant_type" : "client_credentials" as AnyObject,
            "scope" : "ROLE_PRELOGIN" as AnyObject
        ]
        
        self.getAccessTokenImpl(params, onSuccess: onSuccess, onError: onError)
    }
    
    //
    // getAccessTokenImpl (Private Implementation)
    //
    fileprivate static func getAccessTokenImpl(_ parameters: [String:AnyObject], onSuccess: @escaping(_ accessToken: DarwinAccessToken) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri(withContextAndVersion: false))/access-token"
        
        let headers: [String: String] = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with params=\(parameters)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            // .validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(DarwinAccessToken(json: json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinAuthError(statusCode: statusCode, json: json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
   	
}
