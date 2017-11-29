//
//  DirectoryClient.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/21/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class DirectoryClient {
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /directory/destinations
    // Search destinations and resorts by a keyword. Requires an access token (system or user)
    //
    open static func searchDestinations(_ accessToken: DarwinAccessToken!, request: SearchDestinationsRequest, onSuccess: @escaping(_ response: SearchDestinationsResponse) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/directory/destinations"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request: \(request.query!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: ["q" : request.query!], encoding: URLEncoding.default, headers: headers)
            // .validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "[]")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(SearchDestinationsResponse(json: json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }

    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /directory/regions
    // Get a list of regions. Requires an access token (system or user)
    //
    open static func getRegions(_ accessToken: DarwinAccessToken!, onSuccess: @escaping(_ states: [Region]) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/directory/regions"

        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]

        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")

        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            // .validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "[]")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        var regions = [Region]()
                        var parentRegionsDic = [String: Region]()
                        
                        let regionList = json.arrayValue.map { Region(json:$0) }
                    
                        for region in regionList {
                            let rawName = region.regionName!
                            let separatorIndex = rawName.indexOf("-")
                        
                            if separatorIndex != nil {
                                let parentRegionName = rawName.substring(with:rawName.startIndex..<separatorIndex!).trim()
                                let regionName = rawName.substring(with:rawName.index(separatorIndex!, offsetBy: 1)..<rawName.endIndex).trim()
                            
                                var parentRegion = parentRegionsDic[parentRegionName!]
                                if parentRegion == nil {
                                    parentRegion = Region(regionCode: 0, regionName: parentRegionName!)
                                    region.regionName = regionName
                                    parentRegion!.regions.append(region)
                                    parentRegionsDic[parentRegionName!] = parentRegion
                                } else {
                                    region.regionName = regionName
                                    parentRegion!.regions.append(region)
                                }
                            } else {
                                regions.append(region)
                            }
                        }
                    
                        regions.append(contentsOf:Array(parentRegionsDic.values))
                    
                        // Sort 'regions'. Set USA in the first position of the list, and then alphabetically.
                        regions.sort(by: {
                            if $0.regionName == "USA" {
                                return true;
                            } else if $1.regionName == "USA" {
                                return false;
                            } else {
                                return $0.regionName! < $1.regionName!;
                            }
                        })
                    
                        onSuccess(regions)
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
                
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /directory/regions/{regionCode}/areas
    // Get a list of areas by region. Requires an access token (system or user)
    //
    open static func getAreasByRegion(_ accessToken: DarwinAccessToken!, regionCode: Int, onSuccess: @escaping(_ areas: [Area]) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/directory/regions/\(regionCode)/areas"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "[]")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(json.arrayValue.map { Area(json:$0) })
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /directory/areas/{areaCode}
    // Get area details. Requires an access token (system or user)
    //
    open static func getAreaDetails(_ accessToken: DarwinAccessToken!, areaCode: Int, onSuccess: @escaping(_ area: Area) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/directory/areas/\(areaCode)"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(Area(json: json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /directory/areas/{areaCode}/resorts
    // Get a list of resorts by area. Requires an access token (system or user)
    //
    open static func getResortsByArea(_ accessToken: DarwinAccessToken!, areaCode: Int, onSuccess: @escaping(_ resorts: [Resort]) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/directory/areas/\(areaCode)/resorts"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "[]")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(json.arrayValue.map { Resort(summaryJSON: $0) })
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /directory/clubs/{clubCode}/resorts
    // Get a list of resorts by club. Requires an access token (system or user)
    //
    open static func getResortsByClub(_ accessToken: DarwinAccessToken!, clubCode: String, onSuccess: @escaping(_ resorts: [Resort]) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/directory/clubs/\(clubCode)/resorts"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "[]")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(json.arrayValue.map { Resort(summaryJSON: $0) })
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /directory/resorts?northwestLatitude=28&northwestLongitude=-83&southeastLatitude=25&southeastLongitude=-82&maximumOfMiles=300
    // Get a list of resorts within a Geographical Area. Requires an access token (system or user)
    //
    open static func getResortsWithinGeoArea(_ accessToken: DarwinAccessToken!, geoArea: GeoArea?, onSuccess: @escaping(_ resorts: [Resort]) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/directory/resorts"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params: [String: AnyObject] = [
            "northwestLatitude": geoArea?.northWestCoordinate?.latitude as AnyObject,
            "northwestLongitude": geoArea?.northWestCoordinate?.longitude as AnyObject,
            "southeastLatitude": geoArea?.southEastCoordinate?.latitude as AnyObject,
            "southeastLongitude": geoArea?.southEastCoordinate?.longitude as AnyObject,
            "maximumOfMiles": geoArea?.maximunOfMiles as AnyObject,
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and params=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "[]")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(json.arrayValue.map { Resort(summaryJSON: $0) })
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /directory/resorts/{resortCode}
    // Get resort details. Requires an access token (system or user)
    //
    open static func getResortDetails(_ accessToken: DarwinAccessToken!, resortCode: String, onSuccess: @escaping(_ response:Resort) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/directory/resorts/\(resortCode)"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(Resort(detailJSON: json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test PENDING
    // Darwin API endpoint: GET /directory/resorts/{resortCode}/calendars/{year}
    // Get resort special calendar for a year. Requires an access token (system or user)
    //
    open static func getResortCalendars(_ accessToken: DarwinAccessToken!, resortCode: String, year: Int, onSuccess: @escaping(_ resorts: [ResortCalendar]) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/directory/resorts/\(resortCode)/calendars/\(year)"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "[]")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    onSuccess(json.arrayValue.map { ResortCalendar(json: $0) })
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test PENDING
    // Darwin API endpoint: GET /directory/resorts/{resortCode}/weather
    // Get resort weather. Requires an access token (system or user)
    //
    open static func getResortWeather(_ accessToken: DarwinAccessToken!, resortCode: String, onSuccess: @escaping(_ response:ResortWeather) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/directory/resorts/\(resortCode)/weather"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    onSuccess(ResortWeather(json: json))
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /directory/resorts/{resortCode}/matrices
    // Get resort club points chart. Requires an access token (system or user)
    //
    open static func getResortClubPointsChart( _ accessToken: DarwinAccessToken!, resortCode: String, onSuccess: @escaping(_ clubPointsChart:ClubPointsChart) -> Void, onError: @escaping(_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/directory/resorts/\(resortCode)/matrices"
        
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
                        onSuccess(ClubPointsChart(json: json))
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test Passed
    // Darwin API endpoint: GET /directory/resorts/{resortCode}/units/{unitNumber}
    // Get Unit Details. Requires an access token (user)
    //
    open static func getUnitDetails(_ accessToken: DarwinAccessToken!, resortCode: String, unitNumber: String, onSuccess: @escaping(_ unit: InventoryUnit) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/directory/resorts/\(resortCode)/units/\(unitNumber)"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "[]")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    onSuccess(InventoryUnit(json: json))
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }

}
