//
//  ExchangeSearchAvailabilityRequest.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 6/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeSearchAvailabilityRequest {
    
    open var checkInDate : Date?
    open lazy var resortCodes = [String]()
    open var travelParty : TravelParty?
    open lazy var relinquishmentsIds = [String]()
    
    public init() {
    }
    
    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        
        dictionary["checkInDate"] = self.checkInDate!.stringWithShortFormatForJSON() as AnyObject?
        dictionary["resortCodes"] = self.resortCodes as AnyObject?
        dictionary["travelParty"] = self.travelPartyToDictionary() as AnyObject?
        dictionary["relinquishments"] = self.relinquishmentsIds as AnyObject?

        return dictionary
    }
    
    private func travelPartyToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["adults"] = self.travelParty?.adults as AnyObject?
        dictionary["children"] = self.travelParty?.children as AnyObject?
        return dictionary
    }

    open func toJSON() -> JSON {
        return JSON(self.toDictionary())
    }
    
    open func toJSONString() -> String {
        return self.toJSON().rawString()!
    }
    
}
