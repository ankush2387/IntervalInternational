//
//  AvailablePointsUsage.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/19/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AvailablePointsUsage {
    
    open var points : Int? = 0
    open var expirationDate : String?
    open var pointsType : String?
    open var pointsEarnedBy : String?
    
    public init() {
    }

    public convenience init(json:JSON){
        self.init()
        
        self.points = json["points"].intValue
        self.expirationDate = json["expirationDate"].string ?? ""
        self.pointsType = json["pointsType"].string ?? ""
        self.pointsEarnedBy = json["pointsEarnedBy"].string ?? ""
    }
    
}
