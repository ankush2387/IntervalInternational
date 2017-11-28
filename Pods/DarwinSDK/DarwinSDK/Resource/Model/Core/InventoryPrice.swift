//
//  InventoryPrice.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 5/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class InventoryPrice {
    
    open var productCode : String?
    open var price : Float = 0.0
    open var tax : Float = 0.0
    open lazy var taxBreakdown = [InventoryPriceTax]()
    
    public init(){
    }

    public convenience init(json:JSON){
        self.init()
        
        self.productCode = json["productCode"].string ?? ""
        self.price = json["price"].floatValue
        self.tax = json["tax"].floatValue

        if json["taxBreakdown"].exists() {
            let taxBreakdownArrary:[JSON] = json["taxBreakdown"].arrayValue
            self.taxBreakdown = taxBreakdownArrary.map { InventoryPriceTax(json:$0) }
        }
    }
}
