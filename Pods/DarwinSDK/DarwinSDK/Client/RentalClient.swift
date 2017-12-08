//
//  RentalClient.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/21/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class RentalClient {
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: POST /rental/search/dates
    // Rental Pre-Process - Search Dates. Requires an access token (user)
    //
    open static func searchDates(_ accessToken: DarwinAccessToken!, request: RentalSearchDatesRequest!, onSuccess: @escaping(_ response: RentalSearchDatesResponse) -> Void, onError: @escaping(_ error:NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/search/dates"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        //DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                //DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(RentalSearchDatesResponse(json:json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            //.responseString { response in
            //    DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
            //}
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: POST /rental/search/resorts
    // Rental Pre-Process - Search Inventory Availability. Requires an access token (user)
    //
    open static func searchResorts(_ accessToken: DarwinAccessToken!, request: RentalSearchResortsRequest!, onSuccess: @escaping(_ response: RentalSearchResortsResponse) -> Void, onError: @escaping(_ error:NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/search/resorts"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        //DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                //DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(RentalSearchResortsResponse(json:json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            //.responseString { response in
            //    DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
            //}
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: POST /rental/search/regions
    // Rental Search Regions. Requires an access token (user)
    //
    open static func searchRegions(_ accessToken: DarwinAccessToken!, request: RentalSearchRegionsRequest!, onSuccess: @escaping(_ response: [Region]) -> Void, onError: @escaping(_ error:NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/search/regions"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "[]")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    onSuccess(json.arrayValue.map { Region(json:$0) })
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
        
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /rental/top10/destinations
    // Get Top 10 destinations deals. Requires an access token (user)
    //
    open static func getTop10Deals(_ accessToken: DarwinAccessToken!, onSuccess: @escaping(_ resorts: [RentalDeal]) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/top10/destinations"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "[]")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(json.arrayValue.map { RentalDeal(json:$0) })
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
            }
        
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /rental/alerts
    // Get Alerts. Requires an access token (user)
    //
    open static func getAlerts(_ accessToken: DarwinAccessToken!, onSuccess: @escaping(_ alerts: [RentalAlert]) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/alerts"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "[]")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(json.arrayValue.map { RentalAlert(json: $0) })
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /rental/alerts/{alertId}
    // Get Alert by alert Id. Requires an access token (user)
    //
    open static func getAlert(_ accessToken: DarwinAccessToken!, alertId: Int64, onSuccess: @escaping(_ alert: RentalAlert) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/alerts/\(alertId)"
        
        let headers : [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]

        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(RentalAlert(json:json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /rental/alerts/{alertId}/search
    // Search by Alert. Requires an access token (user)
    //
    open static func searchByAlert(_ accessToken: DarwinAccessToken!, alertId: Int64, onSuccess: @escaping(_ response: RentalSearchDatesResponse) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/alerts/\(alertId)/search"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]

        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(RentalSearchDatesResponse(json:json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /rental/alerts/{alertId}/search
    // Search by Alert from Notification Center. Requires an access token (user)
    //
    open static func searchByAlert(_ accessToken: DarwinAccessToken!, alertId: Int64, isForNotification: Bool, onSuccess: @escaping(_ response: RentalSearchDatesResponse) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        DarwinSDK.logger.debug("IsForNotification=\(isForNotification)")
        
        // Delegate in an existng operation
        searchByAlert(accessToken, alertId: alertId, onSuccess: onSuccess, onError: onError)
    }

    // STATUS: Unit Test passed
    // Darwin API endpoint: POST /rental/alerts
    // Create a new Alert. Requires an access token (user)
    //
    open static func createAlert(_ accessToken: DarwinAccessToken!, alert: RentalAlert, onSuccess: @escaping(_ alert: RentalAlert) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/alerts"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = alert.toDictionaryForCreate()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(RentalAlert(json:json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test pending
    // Darwin API endpoint: PUT /rental/alerts/{alertId}
    // Update an existing Alert. Requires an access token (user)
    //
    open static func updateAlert(_ accessToken: DarwinAccessToken!, alert: RentalAlert, onSuccess: @escaping(_ alert: RentalAlert) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/alerts/\(alert.alertId ?? 0)"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = alert.toDictionaryForUpdate()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(RentalAlert(json:json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test pending
    // Darwin API endpoint: DELETE /rental/alerts/{alertId}
    // Delete an existing Alert. Requires an access token (user)
    //
    open static func removeAlert(_ accessToken: DarwinAccessToken!, alertId: Int64, onSuccess: @escaping() -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/alerts/\(alertId)"
        
        // TODO (Frank): Once the API change the DELETE request body as optional then we can remove the headers: Content-Type and Accept
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
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
