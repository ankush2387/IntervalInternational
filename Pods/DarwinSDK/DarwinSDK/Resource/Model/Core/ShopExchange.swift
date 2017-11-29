//
//  ShopExchange.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 7/5/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ShopExchange {
    
    open var discountAmount : Float = 0.0
    open lazy var prices = [InventoryPrice]()
    open lazy var promotions = [Promotion]()
    open var rentalPrice : InventoryPrice?
    open var selectedOfferName : String?
    open var confirmationNumber : String?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.discountAmount = json["discountAmount"].floatValue
        
        if json["prices"].exists() {
            let pricesArrary:[JSON] = json["prices"].arrayValue
            self.prices = pricesArrary.map { InventoryPrice(json:$0) }
        }
        
        if json["promotions"].exists() {
            let promotionsArrary:[JSON] = json["promotions"].arrayValue
            self.promotions = promotionsArrary.map { Promotion(json:$0) }
        }
        
        self.rentalPrice = InventoryPrice()
        self.rentalPrice?.price = json["price"].floatValue
        self.rentalPrice?.tax = json["tax"].floatValue
        if json["taxBreakdown"].exists() {
            let taxBreakdownArrary:[JSON] = json["taxBreakdown"].arrayValue
            self.rentalPrice?.taxBreakdown = taxBreakdownArrary.map { InventoryPriceTax(json:$0) }
        }
        
        self.selectedOfferName = json["selectedOfferName"].string ?? ""
        self.confirmationNumber = json["confirmationNumber"].string ?? ""
    }
    
}

