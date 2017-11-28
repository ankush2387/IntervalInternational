//
//  RestrictedResort.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/26/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RestrictedResort {
    
    open var label : String?
    open lazy var resorts = [Resort]()
   
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.label = json["label"].string ?? ""
        
        if json["restricted"].exists() {
            let resortsJson:[JSON] = json["restricted"].arrayValue
            self.resorts = resortsJson.map { Resort(summaryJSON: $0) }
        }
    }
}
