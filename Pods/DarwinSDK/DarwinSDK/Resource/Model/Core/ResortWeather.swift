//
//  ResortWeather.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 6/1/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ResortWeather {
    
    open var temperature : Temperature?
    open var condition : String?
    open lazy var monthlyAverage = [MonthlyAverage]()
        
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        if json["temperature"].exists() {
            let temperatureJson:JSON = json["temperature"]
            self.temperature = Temperature(json:temperatureJson)
        }
        
        self.condition = json["conditions"].string ?? ""
        
        if json["monthaverage"].exists() {
            let monthlyAverageArrary:[JSON] = json["monthaverage"].arrayValue
            self.monthlyAverage = monthlyAverageArrary.map { MonthlyAverage(json:$0) }
        }
    }
    
}
