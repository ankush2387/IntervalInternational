//
//  OpenWeek.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/15/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class OpenWeek {

    open var relinquishmentId : String?
    open lazy var actions = [String]() // AvailableWeekAction
    open var pointsProgramCode : String?
    open var exchangeStatus : String? // ExchangeStatus
    open var weekNumber : String?
    open var masterUnitNumber : String?
    open var relinquishmentYear : Int?
    open lazy var checkInDates = [String]()
    open var checkInDate : String?
    open var blackedOut : Bool? = false
    open var bulkAssignment : Bool? = false
    open var supplementalWeek : Bool? = false
    open var pointsMatrix : Bool? = false
    open lazy var reservationAttributes = [String]()
    open lazy var virtualWeekActions = [String]()
    open var resort : Resort?
    open var unit : InventoryUnit?
    open var promotion : Promotion?

    public init() {
    }

    public convenience init(json:JSON) {
        self.init()

        self.relinquishmentId = json["relinquishmentId"].string ?? ""
        
        if json["actions"].exists() {
            let actionsJsonArray:[JSON] = json["actions"].arrayValue
            self.actions = actionsJsonArray.map { $0.string! }
        }

        self.pointsProgramCode = json["pointsProgramCode"].string ?? ""
        self.exchangeStatus = json["exchangeStatus"].string ?? ""
        self.weekNumber = json["weekNumber"].string ?? ""
        self.masterUnitNumber = json["masterUnitNumber"].string ?? ""
        self.relinquishmentYear = json["relinquishmentYear"].intValue

        if json["checkInDates"].exists() {
            let checkInDatesJsonArray:[JSON] = json["checkInDates"].arrayValue
            self.checkInDates = checkInDatesJsonArray.map { $0.string! }
        }
        
        self.checkInDate = json["checkInDate"].string ?? ""
        self.blackedOut = json["blackedOut"].boolValue
        self.bulkAssignment = json["bulkAssignment"].boolValue
        self.supplementalWeek = json["supplementalWeek"].boolValue
        self.pointsMatrix = json["pointsMatrix"].boolValue
        
        if json["reservationAttributes"].exists() {
            let reservationAttributesJsonArray:[JSON] = json["reservationAttributes"].arrayValue
            self.reservationAttributes = reservationAttributesJsonArray.map { $0.string! }
        }
        
        if json["virtualWeekActions"].exists() {
            let virtualWeekActionsJsonArray:[JSON] = json["virtualWeekActions"].arrayValue
            self.virtualWeekActions = virtualWeekActionsJsonArray.map { $0.string! }
        }
        
        if json["resort"].exists() {
            let resortJson:JSON = json["resort"]
            self.resort = Resort(detailJSON:resortJson)
        }

        if json["unit"].exists() {
            let unitJson:JSON = json["unit"]
            self.unit = InventoryUnit(json:unitJson)
        }

        if json["promotion"].exists() {
            let promotionJson:JSON = json["promotion"]
            self.promotion = Promotion(json:promotionJson)
        }
    }

}
