//
//  InventoryUnitAmenityDetail.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/17/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class InventoryUnitAmenityDetail {
    
    open var section : String?
    open lazy var descriptions = [String]()
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.section = json["section"].string ?? ""
        if json["descriptions"].exists() {
            let descriptionsArray:[JSON] = json["descriptions"].arrayValue
            self.descriptions = descriptionsArray.map { $0.string! }
        }
    }
    
}
