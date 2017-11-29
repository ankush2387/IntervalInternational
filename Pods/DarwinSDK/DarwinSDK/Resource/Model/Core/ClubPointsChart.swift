//
//  ClubPointsChart.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/19/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ClubPointsChart {
    
    open var type : String?
    open lazy var matrices = [ClubPointsMatrix]()
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.type = json["type"].string ?? ""
        
        if json["matrices"].exists() {
            let matricesJsonArray:[JSON] = json["matrices"].arrayValue
            self.matrices = matricesJsonArray.map { ClubPointsMatrix(json:$0) }
        }
        
    }
    
}

