//
//  ClubPointsMatrixGridRow.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/19/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ClubPointsMatrixGridRow {
    
    open var label : String?
    open lazy var units = [InventoryUnit]()
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.label = json["label"].string ?? ""
        
        if json["units"].exists() {
            let unitsJsonArray:[JSON] = json["units"].arrayValue
            self.units = unitsJsonArray.map { InventoryUnit(json:$0) }
        }
        
    }
    
}

