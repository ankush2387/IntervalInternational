//
//  ExchangeClient.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/15/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation

import Foundation
import Alamofire
import SwiftyJSON

open class ExchangeClient {

    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /exchange/flex/areas
    // Get FlexExchange Deals. Requires an access token (user)
    //
    open static func getFlexExchangeDeals( _ accessToken:DarwinAccessToken!, onSuccess: @escaping (_ deals: [FlexExchangeDeal]) -> Void, onError: @escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/flex/areas"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "[]")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    onSuccess(json.arrayValue.map { FlexExchangeDeal(json:$0) })
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /exchange/relinquishments/view/myUnits
    // Get MyUnits. Requires an access token (user)
    //
    open static func getMyUnits( _ accessToken:DarwinAccessToken!, onSuccess: @escaping (_ myUnits: MyUnits) -> Void, onError: @escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/relinquishments/view/myUnits"

        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]

        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")

        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")

                switch statusCode {
                    case 200...209:
                        // FIXME (Frank) - Filter out bulkAssignment weeks
                        let myUnits = MyUnits(json:json)
                        var openWeeks = [OpenWeek]()

                        for openWeek in myUnits.openWeeks {
                            if openWeek.bulkAssignment == false {
                                openWeeks.append(openWeek)
                            }
                        }

                        myUnits.openWeeks = openWeeks

                        onSuccess(myUnits)
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                    }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /exchange/trips/{confirmationNumber}
    // Get ExchangeTripDetails. Requires an access token (user)
    //
    open static func getExchangeTripDetails( _ accessToken: DarwinAccessToken!, confirmationNumber: String, onSuccess: @escaping (_ exchangeTripDetails: ExchangeDetails) -> Void, onError: @escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/trips/\(confirmationNumber)"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(ExchangeDetails(json:json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /exchange/relinquishments/{relinquishmentId}/pointsMatrix/reservation
    // Update PointsMatrix Reservation. Requires an access token (user)
    //
    open static func updatePointsMatrixReservation( _ accessToken: DarwinAccessToken!, relinquishmentId: String, reservation: PointsMatrixReservation, onSuccess: @escaping () -> Void, onError: @escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/relinquishments/\(relinquishmentId)/pointsMatrix/reservation"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = reservation.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, encoding: JSONEncoding.default, headers: headers)
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
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /exchange/relinquishments/{relinquishmentId}/fixedWeek/reservation
    // Update FixedWeek Reservation. Requires an access token (user)
    //
    open static func updateFixWeekReservation( _ accessToken: DarwinAccessToken!, relinquishmentId: String, reservation: FixWeekReservation, onSuccess: @escaping () -> Void, onError: @escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/relinquishments/\(relinquishmentId)/fixedWeek/reservation"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = reservation.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, encoding: JSONEncoding.default, headers: headers)
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
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: POST /exchange/search/dates
    // Exchange Pre-Process - Search Dates. Requires an access token (user)
    //
    open static func searchDates(_ accessToken: DarwinAccessToken!, request: ExchangeSearchDatesRequest!, onSuccess: @escaping(_ response: ExchangeSearchDatesResponse) -> Void, onError: @escaping(_ error:NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/search/dates"
        
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
                    onSuccess(ExchangeSearchDatesResponse(json:json))
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            //.responseString { response in
            //    DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
            //}
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: POST /exchange/inventory/view/availability
    // Exchange Pre-Process - Search Inventory Availability. Requires an access token (user)
    //
    open static func searchAvailability(_ accessToken: DarwinAccessToken!, request: ExchangeSearchAvailabilityRequest!, onSuccess: @escaping(_ availability: [ExchangeAvailability]) -> Void, onError: @escaping(_ error:NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/inventory/view/availability"
        
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
                    //onSuccess(json.arrayValue.map { ExchangeAvailability(json: $0) })
                    
                    // FIXME(Frank): Only for test UnitSizeUpgrade
                    let result = json.arrayValue.map { ExchangeAvailability(json: $0) }
                    for item in result {
                        item.inventory?.generalUnitSizeUpgradeMessage = true
                    }
                    onSuccess(result)
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
            }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: POST /exchange/filter/relinquishments
    // Exchange Pre-Process - Filter Relinquishments. Requires an access token (user)
    //
    open static func filterRelinquishments(_ accessToken: DarwinAccessToken!, request: ExchangeFilterRelinquishmentsRequest!, onSuccess: @escaping(_ availability: [ExchangeDetails]) -> Void, onError: @escaping(_ error:NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/filter/relinquishments"
        
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
                    onSuccess(json.arrayValue.map { ExchangeDetails(json: $0) })

                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test PENDING
    // Darwin API endpoint: POST /exchange/search/regions
    // Exchange Search Regions. Requires an access token (user)
    //
    open static func searchRegions(_ accessToken: DarwinAccessToken!, request: ExchangeSearchRegionsRequest!, onSuccess: @escaping(_ response: [Region]) -> Void, onError: @escaping(_ error:NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/exchange/search/regions"
        
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

}
