//
//  SearchDatesResponse.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/21/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalSearchDatesResponse {
    
    open lazy var checkInDates = [Date]()
    open lazy var resortCodes = [String]()
    open lazy var surroundingCheckInDates = [Date]()
    open lazy var surroundingResortCodes = [String]()
    
    public init() {
    }

    public convenience init(json:JSON) {
        self.init()

        // Parse check-in dates
		if json["checkInDates"].exists() {
			let checkInDatesArray:[JSON] = json["checkInDates"].arrayValue
            self.checkInDates = checkInDatesArray.map { $0.string!.dateFromShortFormat() }
        }
        
        // Parse resortCodes
		if json["resortCodes"].exists() {
			let resortsCodesArray:[JSON] = json["resortCodes"].arrayValue
            self.resortCodes = resortsCodesArray.map { $0.string! }
        }

        // Parse surroundingCheckInDates
		if json["surroundingCheckInDates"].exists() {
			let surroundingCheckInDatesArray:[JSON] = json["surroundingCheckInDates"].arrayValue
            self.surroundingCheckInDates = surroundingCheckInDatesArray.map { $0.string!.dateFromShortFormat() }
        }
        
        // Parse surroundingResortCodes
		if json["surroundingResortCodes"].exists() {
			let surroundingResortCodesArray:[JSON] = json["surroundingResortCodes"].arrayValue
            self.surroundingResortCodes = surroundingResortCodesArray.map { $0.string! }
        }
    }
    
}
