//
//  Inventory.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 5/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Inventory {
    
    open var priceFrom : Float = 0.0
    open var currencyCode : String?
    open var checkInDate : String?
    open var checkOutDate : String?
    open var matchedDestination : Bool = true
    open lazy var units = [InventoryUnit]()
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.priceFrom = json["priceFrom"].floatValue
        self.currencyCode = json["currencyCode"].string ?? "USD"
        self.matchedDestination = json["matchedDestination"].boolValue
        
		if json["units"].exists() {
			let unitsArrary:[JSON] = json["units"].arrayValue
            self.units = unitsArrary.map { InventoryUnit(json:$0) }
        }
        
        self.checkInDate = json["checkInDate"].string ?? ""
        self.checkOutDate = json["checkOutDate"].string ?? ""
    }
    
}
