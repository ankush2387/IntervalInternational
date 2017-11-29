//
//  ExchangeSearchRegionsRequest.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 9/5/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeSearchRegionsRequest {
    
    open var checkInFromDate : Date?
    open var checkInToDate : Date?
    open var travelParty : TravelParty?
    open lazy var relinquishmentsIds = [String]()
    
    public init() {
    }
    
    open func setCheckInToDate(_ days:Int) {
        if self.checkInFromDate == nil {
            self.checkInFromDate = Date()
        }
        
        self.checkInToDate = self.checkInFromDate!.addingTimeInterval( Double(days) * 60 * 60 * 24)
    }
    
    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        
        dictionary["checkInFromDate"] = self.checkInFromDate!.stringWithShortFormatForJSON() as AnyObject?
        dictionary["checkInToDate"] = self.checkInToDate!.stringWithShortFormatForJSON() as AnyObject?
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
