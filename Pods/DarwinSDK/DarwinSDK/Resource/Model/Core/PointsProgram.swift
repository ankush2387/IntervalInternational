//
//  PointsProgram.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/15/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class PointsProgram {

    open var relinquishmentId : String?
    open lazy var actions = [String]() // AvailableWeekAction
    open var code : String?
    open var availablePoints : Int?
    open var pointsSpent : Int?

    public init() {
    }

    public convenience init(json:JSON) {
        self.init()

        self.relinquishmentId = json["relinquishmentId"].string ?? ""
        
        if json["actions"].exists() {
            let actionsJsonArray:[JSON] = json["actions"].arrayValue
            self.actions = actionsJsonArray.map { $0.string! }
        }

        self.code = json["code"].string ?? ""
        
        if json["availablePoints"].exists() {
            self.availablePoints = json["availablePoints"].intValue
        }

        if json["pointsSpent"].exists() {
            self.pointsSpent = json["pointsSpent"].intValue
        }
    }

}
