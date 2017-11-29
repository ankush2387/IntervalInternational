//
//  ExchangeDestination.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeDestination {
    
    open var checkInDate : String?
    open var checkOutDate : String?
    open var resort : Resort?
    open var unit : InventoryUnit?
    open var cruise : Cruise?
    open var pointsCost : Int?
    open var upgradeCost : Money?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.checkInDate = json["checkInDate"].string ?? ""
        self.checkOutDate = json["checkOutDate"].string ?? ""
        
        if json["resort"].exists() {
            let resortJson:JSON = json["resort"]
            self.resort = Resort(summaryJSON:resortJson)
        }
        
        if json["unit"].exists() {
            let unitJson:JSON = json["unit"]
            self.unit = InventoryUnit(json:unitJson)
        }
        
        if json["cruise"].exists() {
            let cruiseJson:JSON = json["cruise"]
            self.cruise = Cruise(json:cruiseJson)
        }
        
        if json["pointsCost"].exists() {
            self.pointsCost = json["pointsCost"].intValue
        }
        
        if json["upgradeCost"].exists() {
            let upgradeCostJson:JSON = json["upgradeCost"]
            self.upgradeCost = Money(json:upgradeCostJson)
        }
    }

}
