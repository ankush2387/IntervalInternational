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

    open var relinquishmentId : String?
    open var resort : Resort?
    open var pointsSpent : Int?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()

        self.relinquishmentId = json["relinquishmentId"].string ?? ""
        
        if json["resort"].exists() {
            let resortJson:JSON = json["resort"]
            self.resort = Resort(json: resortJson)
        }
        
        if json["pointsSpent"].exists() {
            self.pointsSpent = json["pointsSpent"].intValue
        } else if json["points"].exists() {
            self.pointsSpent = json["points"].intValue
        }

    }
    
}

