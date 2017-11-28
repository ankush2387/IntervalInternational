//
//  InventoryPriceTax.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class InventoryPriceTax {
    
    open var amount : Float = 0.0
    open var description : String?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.amount = json["amount"].floatValue
        self.description = json["description"].string ?? ""
    }
    
}
