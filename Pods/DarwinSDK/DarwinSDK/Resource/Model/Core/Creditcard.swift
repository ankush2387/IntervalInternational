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
    
    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["id"] = self.creditcardId as AnyObject?
        dictionary["cardHolderName"] = self.cardHolderName as AnyObject?
        dictionary["cardNumber"] = self.cardNumber as AnyObject?
        dictionary["type"] = self.typeCode as AnyObject?
        dictionary["cvv"] = self.cvv as AnyObject?
        dictionary["expirationDate"] = self.expirationDate as AnyObject?
        dictionary["preferredCardIndicator"] = self.preferredCardIndicator as AnyObject?
        dictionary["saveCardIndicator"] = self.saveCardIndicator as AnyObject?
        dictionary["autoRenew"] = self.autoRenew as AnyObject?
        dictionary["billingAddress"] = self.billingAddressToDictionary() as AnyObject?
        return dictionary
    }
    
    private func billingAddressToDictionary() -> Dictionary<String, AnyObject> {
        var addressLinesArray = Array<AnyObject>()
        for addressLine in (self.billingAddress?.addressLines)! {
            addressLinesArray.append(addressLine as AnyObject)
        }
        
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["addressLines"] = addressLinesArray as AnyObject?
        dictionary["cityName"] = self.billingAddress?.cityName as AnyObject?
        dictionary["territoryCode"] = self.billingAddress?.territoryCode as AnyObject?
        dictionary["countryCode"] = self.billingAddress?.countryCode as AnyObject?
        dictionary["postalCode"] = self.billingAddress?.postalCode as AnyObject?
        return dictionary
    }
    
}
