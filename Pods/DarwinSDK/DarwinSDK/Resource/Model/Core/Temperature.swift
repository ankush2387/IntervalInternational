//
//  Temperature.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 6/1/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Temperature {
    
    open var fahrenheit : Int = 0
    open var celsius : Int = 0
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.fahrenheit = json["fahrenheit"].intValue
        self.celsius = json["celsius"].intValue
    }

}
