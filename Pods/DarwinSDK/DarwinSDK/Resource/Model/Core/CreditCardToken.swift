//
//  CreditCardToken.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/27/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class CreditCardToken {
    
    open var cardType : String? // CreditCardType
    open var cardNumber : String?
    open var cardToken : String?
    open var offline : Bool = false
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.cardType = json["cardType"].string ?? ""
        self.cardNumber = json["cardNumber"].string ?? ""
        self.cardToken = json["cardToken"].string ?? ""
        self.offline = json["offline"].bool ?? false
    }
    
}

