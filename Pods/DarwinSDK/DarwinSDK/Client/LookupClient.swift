//
//  LookupClient.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/4/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class LookupClient {
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /lookup/countries
    // Get a list of countries. Requires an access token (system or user)
    //
    open static func getCountries(_ accessToken: DarwinAccessToken, onSuccess: @escaping(_ countries: [Country]) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/lookup/countries"
        
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
                        let countryList = json.arrayValue.map { Country(json: $0) }
                        var countries = [Country]()
                        
                        // Clean up countries
                        for country in countryList {
                            if country.countryCode!.trim()!.characters.count == 3 {
                                countries.append(country)
                            }
                        }
                        
                        // Sort 'countries'. Set USA in the first position of the list, and then alphabetically.
                        countries.sort(by: {
                            if $0.countryCode == "USA" {
                                return true
                            } else if $1.countryCode == "USA" {
                                return false
                            } else {
                                return $0.countryName! < $1.countryName!
                            }
                        })
                        
                        onSuccess(countries)

                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /lookup/countries/{countryCode}/states
    // Get a list of states by country. Requires an access token (system or user)
    //
    open static func getStates(_ accessToken: DarwinAccessToken, countryCode: String, onSuccess: @escaping(_ states: [State]) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/lookup/countries/\(countryCode)/states"
        
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
                        let stateList = json.arrayValue.map { State(json: $0) }
                        var states = [State]()
                        
                        for state in stateList {
                            if state.code!.trim()!.characters.count > 0 && state.code!.trim()!.characters.count > 0 {
                                states.append(state)
                            }
                        }
                        
                        // Sort 'states' alphabetically.
                        states.sort(by: {
                            return $0.name! < $1.name!
                        })
                        
                        onSuccess(states)
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /lookup/resorts
    // Get a list of resorts { code, name }. Requires an access token (system or user)
    //
    open static func getResorts(_ accessToken: DarwinAccessToken, onSuccess: @escaping(_ countries: [Resort]) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/lookup/resorts"
        
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
    // Darwin API endpoint: GET /lookup/videos?category=AREA|RESORT|TUTORIAL
    // Get a list of videos by categoty. Requires an access token (system or user)
    //
    open static func getVideos(_ accessToken: DarwinAccessToken, category: VideoCategory, onSuccess: @escaping(_ videos: [Video]) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/lookup/videos"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: ["category": category.rawValue], encoding: URLEncoding.default, headers: headers)
            // .validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "[]")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        onSuccess(json.arrayValue.map { Video(json: $0) })
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
                
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Filter videos where the name containt the search text
    //
    open static func filterVideos( _ videos: [Video], searchText: String) -> [Video] {
        if videos.count == 0 {
            return videos
        }
        
        // Trim the searchText. If no seach text, provided, return the orginal.
        let trimmedSearchStr = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedSearchStr == "" {
            return videos
        }
        
        do {
            // First, convert the search to text to regex pattern.  We'll replace all spaces into pipes, making each word
            // in the search text a unique value
            var regex = try NSRegularExpression(pattern: "\\s+", options: NSRegularExpression.Options.dotMatchesLineSeparators)
            let patternStr = regex.stringByReplacingMatches(in: trimmedSearchStr, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, trimmedSearchStr.characters.count), withTemplate: "|")
            
            // Next, create a new regex to use as a matcher for each video
            regex = try NSRegularExpression(pattern:patternStr, options: NSRegularExpression.Options.dotMatchesLineSeparators)
            
            // Finally, filter the provided vidoes using the patternStr
            let filteredVideos = videos.filter {
                let matches = regex.matches(in: $0.name!, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0,$0.name!.characters.count))
                return matches.count > 0
            }
            
            return filteredVideos
        } catch {
            return videos
        }
    }

    // STATUS: Unit Test PENDING
    // Darwin API endpoint: GET /lookup/magazines
    // Get a list of magazines. Requires an access token (system or user)
    //
    open static func getMagazines( _ accessToken: DarwinAccessToken, onSuccess: @escaping(_ magazines: [Magazine]) -> Void, onError: @escaping(_ error: NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/lookup/magazines"
        
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
                        onSuccess(json.arrayValue.map { Magazine(json: $0) })
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode: statusCode, json: json))
                }
                
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }

}
