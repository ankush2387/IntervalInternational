//
//  MonthlyAverage.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 6/1/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class MonthlyAverage {

    open var month : Int = 0
    open var high : Temperature?
    open var low : Temperature?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.month = json["month"].intValue
        
        if json["high"].exists() {
            let highJson:JSON = json["high"]
            self.high = Temperature(json:highJson)
        }

        if json["low"].exists() {
            let lowJson:JSON = json["low"]
            self.low = Temperature(json:lowJson)
        }
    }
    
}
