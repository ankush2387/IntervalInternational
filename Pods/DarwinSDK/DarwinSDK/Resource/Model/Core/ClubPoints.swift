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
    open var relinquishmentYear : Int?
    open var relinquishmentId : String?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()

        self.relinquishmentId = json["relinquishmentId"].string ?? ""
        self.relinquishmentYear = json["relinquishmentYear"].intValue

        if json["resort"].exists() {
            let resortJson:JSON = json["resort"]
            self.resort = Resort(summaryJSON:resortJson)
        }
        
        if json["pointsSpent"].exists() {
            self.pointsSpent = json["pointsSpent"].intValue
        }
    }
    
}
