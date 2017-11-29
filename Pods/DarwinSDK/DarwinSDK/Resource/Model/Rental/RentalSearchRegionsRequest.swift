//
//  RentalSearchRegionsRequest.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 8/31/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalSearchRegionsRequest {
    
    open var checkInFromDate : Date?
    open var checkInToDate : Date?
    
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
        
        return dictionary
    }
    
    
    open func toJSON() -> JSON {
        return JSON(self.toDictionary())
    }
    
    open func toJSONString() -> String {
        return self.toJSON().rawString()!
    }
    
}
