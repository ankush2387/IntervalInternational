//
//  ExchangeProcessStartRequest.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeProcessStartRequest {
    
    open var travelParty : TravelParty?
    open var destination : ExchangeDestination?
    open var relinquishmentId : String?
    
    public init() {
    }
    
    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["form"] = self.formToDictionary() as AnyObject?
        return dictionary
    }
    
    private func formToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        
        dictionary["travelParty"] = self.travelPartyToDictionary() as AnyObject?
        dictionary["destination"] = self.exchangeDestinationToDictionary() as AnyObject?
        dictionary["relinquishment"] = self.relinquishmentToDictionary() as AnyObject?
        
        return dictionary
    }
    
    private func travelPartyToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["adults"] = self.travelParty?.adults as AnyObject?
        dictionary["children"] = self.travelParty?.children as AnyObject?
        return dictionary
    }
    
    private func exchangeDestinationToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["resort"] = self.resortToDictionary() as AnyObject?
        dictionary["unit"] = self.unitToDictionary() as AnyObject?
        dictionary["checkInDate"] = self.destination?.checkInDate as AnyObject?
        dictionary["checkOutDate"] = self.destination?.checkOutDate as AnyObject?
        return dictionary
    }
    
    private func resortToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["code"] = self.destination?.resort?.resortCode as AnyObject?
        return dictionary
    }
    
    private func unitToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["kitchenType"] = self.destination?.unit?.kitchenType as AnyObject?
        dictionary["unitSize"] = self.destination?.unit?.unitSize as AnyObject?
        dictionary["sleepCapacity"] = self.sleepCapacityToDictionary() as AnyObject?
        return dictionary
    }
    
    private func sleepCapacityToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["public"] = self.destination?.unit?.publicSleepCapacity as AnyObject?
        dictionary["private"] = self.destination?.unit?.privateSleepCapacity as AnyObject?
        return dictionary
    }
    
    private func relinquishmentToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["relinquishmentId"] = self.relinquishmentId as AnyObject?
        return dictionary
    }
    
    open func toJSON() -> JSON {
        return JSON(self.toDictionary())
    }
    
    open func toJSONString() -> String {
        return self.toJSON().rawString()!
    }
}
