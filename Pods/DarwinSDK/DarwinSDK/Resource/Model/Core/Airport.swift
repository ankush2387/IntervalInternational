//
//  Airport.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 7/15/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Airport {
    
    open var code : String?
    open var name : String?
    open var distanceInMiles : Int = 0
    open var distanceInKilometers : Int = 0
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.code = json["code"].string
        self.name = json["name"].string
        
        if json["distance"].exists() {
			let distanceJSON : JSON = json["distance"] as JSON!
            self.distanceInMiles = distanceJSON["miles"].intValue
            self.distanceInKilometers = distanceJSON["kilometers"].intValue
        }
    }

}
