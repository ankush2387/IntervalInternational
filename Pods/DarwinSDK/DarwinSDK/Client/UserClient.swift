//
//  UserService.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/3/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class UserClient {
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /user/profiles/current
    // Get current profile. Requires an access token (user)
    //
    open static func getCurrentProfile( _ accessToken: DarwinAccessToken!, onSuccess: @escaping(_ profile: Contact) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/user/profiles/current"
        
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
                        onSuccess(Contact(json: json))
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /user/profiles/current/creditCards
    // Get credit cards of the current profile. Requires an access token (user)
    //
    open static func getCreditCards( _ accessToken: DarwinAccessToken, onSuccess: @escaping(_ creditCards: [Creditcard]) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/user/profiles/current/creditCards"
        
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
                        onSuccess(json.arrayValue.map { Creditcard(json: $0) })
                
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: POST /user/profiles/current/creditCards
    // Create a new credit card in the current profile. Requires an access token (user)
    //
    open static func createCreditCard( _ accessToken: DarwinAccessToken, creditCard: Creditcard, onSuccess: @escaping(_ creditCard: Creditcard) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/user/profiles/current/creditCards"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = creditCard.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    onSuccess(Creditcard(json: json))
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /user/profiles/current/creditCards/{creditCardId}
    // Update a credit card of the current profile. Requires an access token (user)
    //
    open static func updateCreditCard( _ accessToken: DarwinAccessToken, creditCard: Creditcard, onSuccess: @escaping(_ creditCard: Creditcard) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/user/profiles/current/creditCards/\(creditCard.creditcardId!)"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = creditCard.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    onSuccess(Creditcard(json: json))
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }

    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /user/memberships/current
    // Update membershipNumber in session and get the current Membership. Requires an access token (user)
    //
    open static func updateSessionAndGetCurrentMembership( _ accessToken: DarwinAccessToken!, membershipNumber: String, onSuccess: @escaping(_ membership: Membership) -> Void, onError: @escaping (_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/user/memberships/current"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params: [String: AnyObject] = [
            "membershipNumber": membershipNumber as AnyObject
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(Membership(json: json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }

    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /user/memberships/current
    // Get program available points of the current membership. Requires an access token (user)
    //
    open static func getProgramAvailablePoints(_ accessToken: DarwinAccessToken!, date: String?, onSuccess: @escaping(_ availablePoints: AvailablePoints) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/user/memberships/current/programs/availablePoints"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let asOfDate = (date != nil) ? date : Date().stringWithShortFormatForJSON()

        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and params: \(asOfDate!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: ["asOfDate" : asOfDate!], encoding: URLEncoding.default, headers: headers)
            // .validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(json)")

                switch statusCode {
                    case 200...209:
                        onSuccess(AvailablePoints(json: json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }


    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /user/profiles/current/favorite/resorts
    // Get a list of favorite resorts. Requires an access token (user)
    //
    open static func getFavoriteResorts(_ accessToken: DarwinAccessToken!, onSuccess: @escaping(_ favorites: [ResortFavorite]) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/user/profiles/current/favorite/resorts"
        
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
                        var resortFavorites: [ResortFavorite] = json.arrayValue.map { ResortFavorite(json: $0) }
                        //FIXME(Frank): Temp solution until API send back the list sorted by resort name
                        resortFavorites = resortFavorites.sorted { $0.resort?.resortName?.localizedCaseInsensitiveCompare($1.resort?.resortName ?? "") == ComparisonResult.orderedAscending }
                        onSuccess(resortFavorites)

                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: POST /user/profiles/current/favorite/resorts
    // Add a new favorite resort. Requires an access token (user)
    //
    open static func addFavoriteResort(_ accessToken: DarwinAccessToken!, resortCode: String, onSuccess: @escaping() -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/user/profiles/current/favorite/resorts"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params: [String: AnyObject] = [
            "code": resortCode as AnyObject
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
    // Darwin API endpoint: DELETE /user/profiles/current/favorite/resorts/{resortCode}
    // Delete an existing favorite resort. Requires an access token (user)
    //
    open static func removeFavoriteResort(_ accessToken: DarwinAccessToken!, resortCode: String, onSuccess: @escaping() -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/user/profiles/current/favorite/resorts/\(resortCode)"
        
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
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /user/memberships/current/upcomingTrips
    // Get a list of Upcoming Trips. Requires an access token (user)
    //
    open static func getUpcomingTrips(_ accessToken: DarwinAccessToken!, onSuccess: @escaping(_ upcomingTrips: [UpcomingTrip]) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/user/memberships/current/upcomingTrips"
        
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
                    onSuccess(json.arrayValue.map { UpcomingTrip(json: $0) })
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /user/memberships/current/certificates
    // Get a list of Accommodation Certificates. Requires an access token (user)
    //
    open static func getAccommodationCertificates(_ accessToken: DarwinAccessToken!, onSuccess: @escaping(_ upcomingTrips: [AccommodationCertificate]) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/user/memberships/current/certificates"
        
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
                    onSuccess(json.arrayValue.map { AccommodationCertificate(json: $0) })
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /user/memberships/current/certificates/{certificateNumber}/summary
    // Get the summary for an Accommodation Certificate. Requires an access token (user)
    //
    open static func getAccommodationCertificateSummary(_ accessToken: DarwinAccessToken!, certificateNumber: String, onSuccess: @escaping(_ summary: AccommodationCertificateSummary) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/user/memberships/current/certificates/\(certificateNumber)/summary"
        
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
                    onSuccess(AccommodationCertificateSummary(json: json))
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
}
