//
//  SearchResortsRequest.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/22/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalSearchResortsRequest {
    
    open var checkInDate : Date?
    open var resortCodes : [String]?
    
    public init() {
    }
    
    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        
        dictionary["checkInDate"] = self.checkInDate!.stringWithShortFormatForJSON() as AnyObject?
        dictionary["resortCodes"] = self.resortCodes! as AnyObject?
        
        return dictionary
    }
    
    open func toJSON() -> JSON {
        return JSON(self.toDictionary())
    }
    
    open func toJSONString() -> String {
        return self.toJSON().rawString()!
    }
    
}
