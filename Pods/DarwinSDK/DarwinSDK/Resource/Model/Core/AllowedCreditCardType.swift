//
//  AllowedCreditCardType.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AllowedCreditCardType {
    
    open var name : String?
    open var typeCode : String? // CreditCardType
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.name = json["name"].string ?? ""
        self.typeCode = json["typeCode"].string ?? ""
    }
    
}

