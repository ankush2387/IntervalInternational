//
//  Creditcard.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 1/12/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Creditcard
{
    open var creditcardId : Int?
    open var cardHolderName : String?
    open var typeCode : String?
    open var expirationDate : String?
    open var cardNumber : String?
    open var cvv : String?
    open var billingAddress: Address?
    open var preferredCardIndicator : Bool?
    open var saveCardIndicator : Bool?
    open var autoRenew : Bool?
    
    public init() {
    }
    
    public init(json:JSON) {
        self.creditcardId = json["id"].intValue
        self.cardHolderName = json["cardHolderName"].string
        self.typeCode = json["type"].string
        self.cardNumber = json["cardNumber"].string
        self.cvv = json["cvv"].string ?? ""
        self.preferredCardIndicator = json["preferredCardIndicator"].boolValue
        self.saveCardIndicator = json["saveCardIndicator"].boolValue
        self.autoRenew = json["autoRenew"].boolValue
        
        if let dateStr = json["expirationDate"].string {
            self.expirationDate = dateStr
        }
        
        if let addressJSON = json["billingAddress"] as JSON? {
            self.billingAddress = Address(json: addressJSON)
        }
    }
    
}
