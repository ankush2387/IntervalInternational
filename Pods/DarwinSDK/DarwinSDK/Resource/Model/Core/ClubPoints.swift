//
//  ClubPoints.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ClubPoints {

    open var resort : Resort?
    open var pointsSpent : Int?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()

        if json["resort"].exists() {
            let resortJson:JSON = json["resort"]
            self.resort = Resort(summaryJSON:resortJson)
        }
        
        if json["pointsSpent"].exists() {
            self.pointsSpent = json["pointsSpent"].intValue
        }
    }
    
}

