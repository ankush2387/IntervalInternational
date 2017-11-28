//
//  CreditCardTokenizeClient.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/25/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
        
open class CreditCardTokenizeClient {
    
    // STATUS: Unit Test passed
    // Tokenize API endpoint: POST /creditCards
    // Get a Credit Card Token for a Credit Card Number. Requires an access token (user)
    //
    open static func tokenize(_ accessToken: DarwinAccessToken!, creditCardNumber: String, onSuccess: @escaping(_ creditCardToken: CreditCardToken) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getTokenizeApiUri())/creditCards"
 
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        // "cardNumber": creditCardNumber as AnyObject? ?? "" as AnyObject
        let params: [String: AnyObject] = [
            "cardNumber": (creditCardNumber as AnyObject?)! 
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
  
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(CreditCardToken(json:json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
}
