//
//  CruiseSupplementalPayment.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class CruiseSupplementalPayment {
    
    open var depositAmount : Money?
    open var balanceDueAmount : Money?
    open var balanceDueDate : String?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()

        if json["depositAmount"].exists() {
            let depositAmountJson:JSON = json["depositAmount"]
            self.depositAmount = Money(json:depositAmountJson)
        }
        
        if json["balanceDueAmount"].exists() {
            let balanceDueAmountJson:JSON = json["balanceDueAmount"]
            self.balanceDueAmount = Money(json:balanceDueAmountJson)
        }
        
        self.balanceDueDate = json["balanceDueDate"].string ?? ""
    }
    
}

