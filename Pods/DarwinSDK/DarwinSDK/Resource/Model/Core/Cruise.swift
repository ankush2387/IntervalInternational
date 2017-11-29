//
//  Cruise.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Cruise {
    
    open var shipName : String?
    open var tripName : String?
    open lazy var images = [Image]()
    open var cabin : Cabin?
    open var unavailableInfoReason : String?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.shipName = json["shipName"].string ?? ""
        self.tripName = json["tripName"].string ?? ""
        
        if json["images"].exists() {
            let imagesArrary:[JSON] = json["images"].arrayValue
            self.images = imagesArrary.map { Image(json:$0) }
        }
        
        if json["cabin"].exists() {
            let cabinJson:JSON = json["cabin"]
            self.cabin = Cabin(json:cabinJson)
        }
        
        self.unavailableInfoReason = json["unavailableInfoReason"].string ?? ""
    }
    
}

