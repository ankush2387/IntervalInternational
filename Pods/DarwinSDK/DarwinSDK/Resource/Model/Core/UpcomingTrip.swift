//
//  UpcomingTrip.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/30/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class UpcomingTrip {
    
    open var type : String? // ExchangeTransactionType
    open var exchangeNumber : Int64?
    open var exchangeStatus : String? // ExchangeStatus
    open var checkInDate : String?
    open var checkOutDate : String?
    open var resort : Resort?
    open var unit : InventoryUnit?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.type = json["type"].string ?? ""
        
        if json["exchangeNumber"].exists() {
            self.exchangeNumber = json["exchangeNumber"].int64Value
        }
        
        self.exchangeStatus = json["exchangeStatus"].string ?? ""
        
        self.checkInDate = json["checkInDate"].string ?? ""
        self.checkOutDate = json["checkOutDate"].string ?? ""
        
        if json["resort"].exists() {
            let resortJson:JSON = json["resort"]
            self.resort = Resort(json: resortJson)
        }
        
        if json["unit"].exists() {
            let unitJson:JSON = json["unit"]
            self.unit = InventoryUnit(json:unitJson)
        }
    }
    
}


