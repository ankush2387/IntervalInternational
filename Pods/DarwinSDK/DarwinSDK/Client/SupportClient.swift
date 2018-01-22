//
//  SupportClient.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 8/18/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class SupportClient {
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: GET /support/config/current
    // Get Business Configs. Requires an access token (system or user)
    //
    open static func getSettings(_ accessToken: DarwinAccessToken, onSuccess: @escaping(_ settings: Settings) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/support/config/current"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            // .validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                case 200...209:
                    onSuccess(Settings(json:json))
                    
                default:
                    onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    open static func getStaticSettings(_ accessToken: DarwinAccessToken, onSuccess: @escaping(_ settings: Settings) -> Void, onError: @escaping(_ error: NSError) -> Void) {
        
        let vacationSearchSettings = VacationSearchSettings();
        vacationSearchSettings.bookingIntervalDateStrategy = BookingIntervalDateStrategy.FIRST.rawValue
        vacationSearchSettings.collapseBookingIntervalsOnChange = true
        vacationSearchSettings.vacationSearchTypes = [VacationSearchType.COMBINED.rawValue,
                                                      VacationSearchType.RENTAL.rawValue, VacationSearchType.EXCHANGE.rawValue]
        
        let iOS = AppSettings()
        iOS.currentVersion = "3.5.2"
        iOS.currentVersionAlert = "There is a newer version of the Interval App.  Do you want to download it now?"
        iOS.minimumSupportedVersion = "3.5.0"
        iOS.minimumSupportedVersionAlert = "There is a newer version of the Interval App.  Do you want to download it now?"
        
        let android = AppSettings()
        android.currentVersion = "3.5.2"
        android.currentVersionAlert = "There is a newer version of the Interval App.  Do you want to download it now?"
        android.minimumSupportedVersion = "3.5.0"
        android.minimumSupportedVersionAlert = "There is a newer version of the Interval App.  Do you want to download it now?"
        
        let settings = Settings()
        settings.vacationSearch = vacationSearchSettings
        settings.ios = iOS
        settings.android = android
        
        onSuccess(settings)
    }
}

