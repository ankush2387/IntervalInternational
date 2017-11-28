//
//  InventoryUnit.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 5/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class InventoryUnit {
    
    open var unitSize : String?
    open var kitchenType : String?
    open var matchedUnit : Bool = true
    open var priorityViewing : Bool = false
    open var publicSleepCapacity : Int = 0
    open var privateSleepCapacity : Int = 0
    open var tradeOutCapacity : Int = 0
    open var discountAmount : Float = 0.0
    open var discountType : String?
    open var discountCode : String?
    open var unitNumber : String?
    open var checkInDate : String?
    open var checkOutDate : String?
    open var platinumScape : Bool = false
    open var clubPoints : Int = 0
    open lazy var amenities = [InventoryUnitAmenity]()
    open lazy var prices = [InventoryPrice]()
    open lazy var promotions = [Promotion]()
    open lazy var lockOffUnits = [InventoryUnit]()
    open var lockOffIndicator : Bool = false
    open var trackCodeCategory : String?
    open var vacationSearchType : VacationSearchType?
    
    public init() {
    }

    public convenience init(checkInDate:String?, checkOutDate:String?, unitSize:UnitSize?, kitchenType:KitchenType?) {
        self.init()
        
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
        self.unitSize = unitSize?.rawValue
        self.kitchenType = kitchenType?.rawValue
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.unitSize = json["unitSize"].string ?? UnitSize.Unknown.rawValue
        self.kitchenType = json["kitchenType"].string ?? KitchenType.Unknown.rawValue
        self.matchedUnit = json["matchedUnit"].boolValue
        self.priorityViewing = json["priorityViewing"].boolValue
        
        if let sleepCapacityJSON = json["sleepCapacity"] as JSON? {
            self.publicSleepCapacity = sleepCapacityJSON["public"].intValue
            self.privateSleepCapacity = sleepCapacityJSON["private"].intValue
        }
		self.tradeOutCapacity = json["tradeOutCapacity"].intValue

        if let discountJSON = json["discount"] as JSON? {
            self.discountAmount = discountJSON["amount"].floatValue
            self.discountType = discountJSON["type"].string ?? ""
            self.discountCode = discountJSON["code"].string ?? ""
        }
        
        self.unitNumber = json["unitNumber"].string ?? ""
        self.checkInDate = json["checkInDate"].string ?? ""
        self.checkOutDate = json["checkOutDate"].string ?? ""
        self.platinumScape = json["platinumScape"].boolValue
        self.clubPoints = json["clubPoints"].intValue
        
        if json["amenities"].exists() {
            let amenitiesArrary:[JSON] = json["amenities"].arrayValue
            self.amenities = amenitiesArrary.map { InventoryUnitAmenity(json:$0) }
        }
        
        if json["prices"].exists() {
            let pricesArrary:[JSON] = json["prices"].arrayValue
            self.prices = pricesArrary.map { InventoryPrice(json:$0) }
        }
        
        if json["promotions"].exists() {
            let promotionsArrary:[JSON] = json["promotions"].arrayValue
            self.promotions = promotionsArrary.map { Promotion(json:$0) }
        }
        
        if json["lockOffUnits"].exists() {
            let lockOffUnitsArrary:[JSON] = json["lockOffUnits"].arrayValue
            self.lockOffUnits = lockOffUnitsArrary.map { InventoryUnit(json:$0) }
        }
        
        self.lockOffIndicator = json["lockOffIndicator"].boolValue
        self.trackCodeCategory = json["trackCode"].string ?? ""
    }
  
    open func getPriceForProduct(product:Product) -> InventoryPrice? {
		return self.getPriceForProduct(productCode:product.productCode ?? "BSC")
    }

    open func getPriceForProduct(productCode:String) -> InventoryPrice? {
        for price in self.prices {
            if price.productCode == productCode {
                return price
            }
        }
        return nil
    }
    
}