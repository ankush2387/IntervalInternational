//
//  TravelParty.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class TravelParty {

    open var adults : Int = 0
    open var children : Int = 0
    open var seniors : Int = 0
    open var infants : Int = 0
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.adults = json["adults"].intValue
        self.children = json["children"].intValue
        self.seniors = json["seniors"].intValue
        self.infants = json["infants"].intValue
    }
    
}
