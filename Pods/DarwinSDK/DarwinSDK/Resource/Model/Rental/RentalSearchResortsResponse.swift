//
//  SearchResortsResponse.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/22/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalSearchResortsResponse {
    
    open lazy var resorts = [Resort]()
    open var totalResorts : Int = 0
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        if json["resorts"].exists() {
            let resortsArray:[JSON] = json["resorts"].arrayValue
            self.resorts = resortsArray.map { Resort(json: $0) }
        }
        
        self.totalResorts = json["totalResorts"].intValue
    }
    
}
