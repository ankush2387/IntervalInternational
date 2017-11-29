//
//  Amenity.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 7/14/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ResortAmenity {
    
    open var amenityCode : String?
    open var amenityName : String?
    open var nearby : Bool = false
    open var onsite : Bool = false
    
    public init() {
    }
    
    public convenience init(amenityCode:String, amenityName:String) {
        self.init()
        
        self.amenityCode = amenityCode
        self.amenityName = amenityName
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.amenityCode = json["code"].string ?? ""
        self.amenityName = json["name"].string ?? ""
        self.nearby = json["nearby"].boolValue
        self.onsite = json["onsite"].boolValue
    }
    
}
