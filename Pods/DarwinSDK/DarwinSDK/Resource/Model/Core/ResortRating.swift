//
//  ResortRating.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 7/15/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ResortRating {
    
    open var totalResponses : Int = 0
    open var months : Int = 0
    open var scale : Int = 5
    open lazy var categories = [ResortRatingCategory]()
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.totalResponses = json["responses"].intValue
        self.months = json["months"].intValue
        if let value = json["maxValue"].int {
            self.scale = value
        } else {
            self.scale = 5
        }
        
		if json["values"].exists() {
			let categoryArray:[JSON] = json["values"].arrayValue
            self.categories = categoryArray.map { ResortRatingCategory(json:$0) }
        }
    }
    
}
