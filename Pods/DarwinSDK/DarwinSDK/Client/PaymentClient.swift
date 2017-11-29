//
//  PaymentClient.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 8/1/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class PaymentClient {
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /lookup/countries
    // Resend Confirmation. Requires an access token (system or user)
    //
    open static func resendConfirmation(_ accessToken: DarwinAccessToken, confirmationNumber: String, emailAddress: String, onSuccess: @escaping() -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/payment/exchanges/\(confirmationNumber)/resendExchangeConfirmation"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        var params = Dictionary<String, AnyObject>()
        params["email"] = emailAddress as AnyObject?
       
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            // .validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    onSuccess()
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
}


