//
//  Guest.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Guest {
    
    open var firstName : String?
    open var lastName : String?
    open var address : Address?
    open lazy var phones = [Phone]()
    open var primaryTraveler : Bool = false
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.firstName = json["firstName"].string ?? ""
        self.lastName = json["lastName"].string ?? ""
        
        if json["address"].exists() {
            self.address = Address(json: json["address"])
        }
        
        if json["telephones"].exists() {
            let phonesArrary:[JSON] = json["telephones"].arrayValue
            self.phones = phonesArrary.map { Phone(json:$0) }
        }
        
        self.primaryTraveler = json["primaryTraveler"].boolValue
    }
    
    open func toDictionary() -> Dictionary<String, AnyObject> {
        var phonesArray = Array<AnyObject>()
        for phone in phones {
            phonesArray.append(phone.toDictionary() as AnyObject)
        }
        
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["firstName"] = firstName as AnyObject?
        dictionary["lastName"] = lastName as AnyObject?
        dictionary["address"] = self.addressToDictionary() as AnyObject?
        dictionary["telephones"] = phonesArray as AnyObject?
        dictionary["primaryTraveler"] = primaryTraveler as AnyObject?
        return dictionary
    }
    
    private func addressToDictionary() -> Dictionary<String, AnyObject> {
        var addressLinesArray = Array<AnyObject>()
        for addressLine in (address?.addressLines)! {
            addressLinesArray.append(addressLine as AnyObject)
        }
        
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["type"] = self.address?.addressType as AnyObject?
        dictionary["addressLines"] = addressLinesArray as AnyObject?
        dictionary["cityName"] = self.address?.cityName as AnyObject?
        dictionary["territoryCode"] = self.address?.territoryCode as AnyObject?
        dictionary["countryCode"] = self.address?.countryCode as AnyObject?
        dictionary["postalCode"] = self.address?.postalCode as AnyObject?
        return dictionary
    }
    
}
