//
//  RentalDeal.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 5/31/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalDeal {

    open var header : String?
    open var details : String?
    open var fromDate : Date?
    open var toDate : Date?
    open lazy var images = [Image]()
    open var price : RentalDealPrice?
    open lazy var areaCodes = [Int]()
    open lazy var resortCodes = [String]()
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.header = json["header"].string ?? ""
        self.details = json["details"].string ?? ""
        
        if let dateStr = json["fromDate"].string {
            self.fromDate = dateStr.dateFromShortFormat()
        }
        if let dateStr = json["toDate"].string {
            self.toDate = dateStr.dateFromShortFormat()
        }
        
        if json["images"].exists() {
            let imagesArray:[JSON] = json["images"].arrayValue
            self.images = imagesArray.map { Image(json:$0) }
        }
        
        if json["price"].exists() {
            let priceJson:JSON = json["price"]
            self.price = RentalDealPrice(json:priceJson)
        }
        
		if json["resortCodes"].exists() {
			let resortsCodesArray:[JSON] = json["resortCodes"].arrayValue
            self.resortCodes = resortsCodesArray.map { $0.string! }
        }

		if json["areaCodes"].exists() {
			let areaCodesArray:[JSON] = json["areaCodes"].arrayValue
            self.areaCodes = areaCodesArray.map { $0.int! }
        }
    }
    
    open func getCheckInDate() -> Date {
        if let price = price, let checkInDate = price.checkInDate {
            return checkInDate
        } else {
            // FIXME(Frank): Derive a date in the middle of: deal.fromDate and deal.toDate
            return self.fromDate!
        }
    }
    
}
