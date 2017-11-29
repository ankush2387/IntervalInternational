//
//  RestrictedArea.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/26/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RestrictedArea {
    
    open var label : String?
    open lazy var areas = [Area]()
    
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.label = json["label"].string ?? ""
        
        if json["restricted"].exists() {
            let areasJson:[JSON] = json["restricted"].arrayValue
            self.areas = areasJson.map { Area(json: $0) }
        }
    }
}
