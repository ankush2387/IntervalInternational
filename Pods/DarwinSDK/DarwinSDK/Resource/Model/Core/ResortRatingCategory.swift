//
//  ResortRatingCategory.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 7/15/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ResortRatingCategory {
    
    open var rating : Float = 0.0
    open var categoryCode : String?
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.rating = json["rating"].floatValue
        self.categoryCode = json["code"].string
    }
    
}
