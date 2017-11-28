//
//  Coordinate.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/21/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Coordinates {
    
    open var latitude : Double = 0.0
    open var longitude : Double = 0.0
    open var accuaryLevel : Int = 0
    open var accuaryPercent : Double = 0.0

    public init() {
    }
    
    public convenience init(latitude:Double, longitude:Double) {
        self.init()
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.latitude = json["latitude"].doubleValue
        self.longitude = json["longitude"].doubleValue
        
        if let accuracyJSON = json["accuracy"] as JSON? {
            self.accuaryLevel = accuracyJSON["level"].intValue
            self.accuaryPercent = accuracyJSON["percent"].doubleValue / 100.0
        }
    }
    
}
