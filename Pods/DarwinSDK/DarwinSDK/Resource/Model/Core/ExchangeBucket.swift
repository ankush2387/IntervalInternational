//
//  ExchangeBucket.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 6/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeBucket {
    
    open var pointsCost : Int = 0
    open var memberPointsRequired : Int = 0
    open var trackCodeCategory : String?
    open var matchetUnit : Bool = false
    open var upgradeFromSize : Int = 0
    open var upgradeToSize : Int = 0
    open var unit : InventoryUnit?
    open lazy var promotions = [Promotion]()
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.pointsCost = json["pointsCost"].intValue
        self.memberPointsRequired = json["memberPointsRequired"].intValue
        self.trackCodeCategory = json["trackCodeCategory"].string ?? ""
        self.matchetUnit = json["matchetUnit"].boolValue
        self.upgradeFromSize = json["upgradeFromSize"].intValue
        self.upgradeToSize = json["upgradeToSize"].intValue
        
        if json["unit"].exists() {
            let unitJson:JSON = json["unit"]
            self.unit = InventoryUnit(json:unitJson)
        }
        
        if json["promotions"].exists() {
            let promotionsArray:[JSON] = json["promotions"].arrayValue
            self.promotions = promotionsArray.map { Promotion(json:$0) }
        }
    }
}
