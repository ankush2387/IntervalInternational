//
//  State.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class State {
    
    open var code : String?
    open var name : String?
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.code = json["code"].string
        self.name = json["name"].string
    }
    
}

