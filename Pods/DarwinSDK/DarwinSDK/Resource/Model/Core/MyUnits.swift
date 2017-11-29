//
//  MyUnits.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/15/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class MyUnits {

    open var pointsProgram : PointsProgram?
    open lazy var openWeeks = [OpenWeek]()
    open lazy var deposits = [Deposit]()

    public init() {
    }

    public convenience init(json:JSON) {
        self.init()

        if json["pointsProgram"].exists() {
            let pointsProgramJson:JSON = json["pointsProgram"]
            self.pointsProgram = PointsProgram(json:pointsProgramJson)
        }

        if json["openWeeks"].exists() {
            let openWeeksJsonArray:[JSON] = json["openWeeks"].arrayValue
            self.openWeeks = openWeeksJsonArray.map { OpenWeek(json:$0) }
        }

        if json["deposits"].exists() {
            let depositsJsonArray:[JSON] = json["deposits"].arrayValue
            self.deposits = depositsJsonArray.map { Deposit(json:$0) }
        }
    }

}

