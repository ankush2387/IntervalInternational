//
//  RentalDestination.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 4/11/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalDestination {
    
    open var checkInDate : String?
    open var checkOutDate : String?
    open var resort : Resort?
    open var unit : InventoryUnit?
    open var pointsCost : Int?
    
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
        
        if json["pointsCost"].exists() {
            self.pointsCost = json["pointsCost"].intValue
        }
    }
    
}
