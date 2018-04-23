//
//  ExchangeAvailability.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 6/20/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeAvailability {
    
    open var resort : Resort?
    open var inventory : ExchangeInventory?
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        if json["resort"].exists() {
            let resortJson:JSON = json["resort"]
            self.resort = Resort(json: resortJson)
        }
        
        if json["inventory"].exists() {
            let inventoryJson:JSON = json["inventory"]
            self.inventory = ExchangeInventory(json:inventoryJson)
        }
    }
    
}
