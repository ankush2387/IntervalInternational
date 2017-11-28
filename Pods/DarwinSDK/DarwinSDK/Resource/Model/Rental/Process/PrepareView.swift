//
//  PrepareView.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class PrepareView {
    
    open lazy var actions = [String]() // ProcessAction
    open lazy var promoCodes = [String]()
    open var resort : Resort?
    open var unit : InventoryUnit?
    open var fees : RentalFees?
    open var forceRenewals : ForceRenewals?
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()

        if json["actions"].exists() {
            let actionsArray:[JSON] = json["actions"].arrayValue
            self.actions = actionsArray.map { $0.string! }
        }
        
        if json["promoCodes"].exists() {
            let promoCodesArray:[JSON] = json["promoCodes"].arrayValue
            self.promoCodes = promoCodesArray.map { $0.string! }
        }
        
        if json["resort"].exists() {
            self.resort = Resort(detailJSON: json["resort"])
        }
        
        if json["unit"].exists() {
            self.unit = InventoryUnit(json: json["unit"])
        }
        
        if json["fees"].exists() {
            self.fees = RentalFees(json: json["fees"])
        }
        
        if json["forceRenewals"].exists() {
            self.forceRenewals = ForceRenewals(json: json["forceRenewals"])
        }
    }
    
}
