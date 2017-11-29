//
//  UnitSizeUpgrade.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 7/5/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class UnitSizeUpgrade {
    
    open var price : Float = 0.0
    open lazy var prices = [InventoryPrice]()
    open lazy var promotions = [Promotion]()
    open var selectedOfferName : String?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.price = json["price"].floatValue
        
        if json["prices"].exists() {
            let pricesArrary:[JSON] = json["prices"].arrayValue
            self.prices = pricesArrary.map { InventoryPrice(json:$0) }
        }
        
        if json["promotions"].exists() {
            let promotionsArrary:[JSON] = json["promotions"].arrayValue
            self.promotions = promotionsArrary.map { Promotion(json:$0) }
        }
        
        self.selectedOfferName = json["selectedOfferName"].string ?? ""
    }
    
}
