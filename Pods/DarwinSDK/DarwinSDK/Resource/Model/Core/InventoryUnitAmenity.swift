//
//  InventoryUnitAmenity.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/17/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class InventoryUnitAmenity {
    
    open var category : String?
    open lazy var details = [InventoryUnitAmenityDetail]()
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.category = json["category"].string ?? ""
        if json["details"].exists() {
            let detailsArrary:[JSON] = json["details"].arrayValue
            self.details = detailsArrary.map { InventoryUnitAmenityDetail(json:$0) }
        }
    }
    
}
