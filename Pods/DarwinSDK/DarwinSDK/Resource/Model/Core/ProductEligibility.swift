//
//  ProductEligibility.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 9/20/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ProductEligibility {
    
    open var productCode : String?
    open var isEligible : Bool = false
    open var reason : String?
    

    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.productCode = json["productCd"].string ?? ""
        self.isEligible = json["eligible"].boolValue
        self.reason = json["reason"].string ?? ""
    }
    
}
