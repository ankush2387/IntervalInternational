//
//  Eplus.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Eplus {
    
    open var price : Float = 0.0
    open var purchased : Bool?
    open var selected : Bool?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.price = json["price"].floatValue
        
        if let value = json["purchased"].bool {
            self.purchased = value
        }
        
        if let value = json["selected"].bool {
            self.selected = value
        }
    }
    
}

