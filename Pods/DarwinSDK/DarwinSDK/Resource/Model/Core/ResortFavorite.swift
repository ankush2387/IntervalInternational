//
//  ResortFavorite.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/13/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ResortFavorite {
    
    open var resort : Resort?
    open var createdDate : String?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()

        if json["resort"].exists() {
            let resortJson:JSON = json["resort"]
            self.resort = Resort(json: resortJson)
        }
        
        self.createdDate = json["createdDate"].string ?? ""
    }
    
}

