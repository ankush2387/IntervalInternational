//
//  AvailablePoints.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/19/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AvailablePoints {
    
    open var inquiryDate : String?
    open var pointsProgramCode : String?
    open var availablePoints : Int? = 0
    open lazy var usage = [AvailablePointsUsage]()
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.inquiryDate = json["inquiryDate"].string ?? ""
        self.pointsProgramCode = json["pointsProgramCode"].string ?? ""
        self.availablePoints = json["availablePoints"].intValue
        
        if json["usage"].exists() {
            let usageJsonArray:[JSON] = json["usage"].arrayValue
            self.usage = usageJsonArray.map { AvailablePointsUsage(json:$0) }
        }

    }
    
}

