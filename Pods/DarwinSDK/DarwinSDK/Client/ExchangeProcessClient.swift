//
//  ExchangeProcessClient.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 6/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class ExchangeProcessClient {
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: POST /exchange/shop/processes
    // Exchange Shop Process - Start. Requires an access token (user)
    //
    open static func start( _ accessToken:DarwinAccessToken!, process:ExchangeProcess!, request:ExchangeProcessStartRequest!, onSuccess:@escaping (_ response:ExchangeProcessPrepareResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/shop/processes"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    let exchangeProcessPrepareResponse = ExchangeProcessPrepareResponse(json:json)
                    // Update the ExchangeProcess ref
                    onSuccess(exchangeProcessPrepareResponse)
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /exchange/shop/processes/{processId}/prepare/continue
    // Exchange Shop Process - Continue To Checkout. Requires an access token (user)
    //
    open static func continueToCheckout( _ accessToken:DarwinAccessToken!, process:ExchangeProcess!, request:ExchangeProcessContinueToCheckoutRequest!, onSuccess:@escaping (_ response:ExchangeProcessRecapResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/shop/processes/\(process!.processId)/prepare/continue"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    let exchangeProcessRecapResponse = ExchangeProcessRecapResponse(json:json)
                    // Update the ExchangeProcess ref
                    onSuccess(exchangeProcessRecapResponse)
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /exchange/shop/processes/{processId}/prepare/back
    // Exchange Shop Process - Back To Choose Exchange. Requires an access token (user)
    //
    open static func backToChooseExchange( _ accessToken:DarwinAccessToken!, process:ExchangeProcess!, onSuccess:@escaping (_ response:ExchangeProcessEndResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/shop/processes/\(process!.processId)/prepare/back"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = Dictionary<String, AnyObject>()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    let exchangeProcessEndResponse = ExchangeProcessEndResponse(json:json)
                    // Update the ExchangeProcess ref
                    onSuccess(exchangeProcessEndResponse)
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test pending
    // Darwin API endpoint: PUT /exchange/shop/processes/{processId}/recap/process-promotion-code
    // Exchange Shop Process - Apply Promo Code. Requires an access token (user)
    //
    open static func applyPromoCode( _ accessToken:DarwinAccessToken!, process:ExchangeProcess!, request:ExchangeProcessApplyPromoCodeRequest!, onSuccess:@escaping (_ response:ExchangeProcessRecapResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/shop/processes/\(process!.processId)/recap/process-promotion-code"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    let exchangeProcessRecapResponse = ExchangeProcessRecapResponse(json:json)
                    // Update the ExchangeProcess ref
                    onSuccess(exchangeProcessRecapResponse)
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /exchange/shop/processes/{processId}/recap/recalculate
    // Exchange Shop Process - Recalculate Fees. Requires an access token (user)
    //
    open static func recalculateFees( _ accessToken:DarwinAccessToken!, process:ExchangeProcess!, request:ExchangeProcessRecalculateRequest!, onSuccess:@escaping (_ response:ExchangeProcessRecapResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/shop/processes/\(process!.processId)/recap/recalculate"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    let exchangeProcessRecapResponse = ExchangeProcessRecapResponse(json:json)
                    // Update the ExchangeProcess ref
                    onSuccess(exchangeProcessRecapResponse)
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /exchange/shop/processes/{processId}/recap/continue
    // Exchange Shop Process - Continue To Pay. Requires an access token (user)
    //
    open static func continueToPay( _ accessToken:DarwinAccessToken!, process:ExchangeProcess!, request:ExchangeProcessContinueToPayRequest!, onSuccess:@escaping (_ response:ExchangeProcessEndResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/shop/processes/\(process!.processId)/recap/continue"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    let exchangeProcessEndResponse = ExchangeProcessEndResponse(json:json)
                    // Update the ExchangeProcess ref
                    onSuccess(exchangeProcessEndResponse)
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /exchange/shop/processes/{processId}/recap/back
    // Exchange Shop Process - Back To Who Is Checking. Requires an access token (user)
    //
    open static func backToWhoIsChecking( _ accessToken:DarwinAccessToken!, process:ExchangeProcess!, onSuccess:@escaping (_ response:ExchangeProcessPrepareResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/shop/processes/\(process!.processId)/recap/back"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = Dictionary<String, AnyObject>()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    let exchangeProcessPrepareResponse = ExchangeProcessPrepareResponse(json:json)
                    // Update the ExchangeProcess ref
                    onSuccess(exchangeProcessPrepareResponse)
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
}
