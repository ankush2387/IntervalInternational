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
    open var relinquishmentYear : Int?
    open var exchangeStatus : String? // ExchangeStatus
    open var weekNumber : String? // WeekNumber
    open var masterUnitNumber : String?
    open lazy var checkInDates = [String]()
    open var checkInDate : String?
    open var checkOutDate : String?
    open var pointsProgramCode : String? // PointsProgramCode
    open var resort : Resort?
    open var unit : InventoryUnit?
    open var pointsMatrix : Bool? = false
    open var blackedOut : Bool? = false
    open var bulkAssignment : Bool? = false
    open var memberUnitLocked : Bool? = false
    open var payback : Bool? = false
    open var waitList : Bool? = false
    open var waitListNumber : Int = 0
    open lazy var reservationAttributes = [String]() // ReservationAttribute
    open lazy var virtualWeekActions = [String]() // VirtualWeekAction
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

        self.relinquishmentYear = json["relinquishmentYear"].intValue
        self.exchangeStatus = json["exchangeStatus"].string ?? ""
        self.weekNumber = json["weekNumber"].string ?? ""
        self.masterUnitNumber = json["masterUnitNumber"].string ?? ""
        
        if json["checkInDates"].exists() {
            let checkInDatesJsonArray:[JSON] = json["checkInDates"].arrayValue
            self.checkInDates = checkInDatesJsonArray.map { $0.string! }
        }
        
        self.checkInDate = json["checkInDate"].string ?? ""
        self.checkOutDate = json["checkOutDate"].string ?? ""
        self.pointsProgramCode = json["pointsProgramCode"].string ?? ""
        
        if json["resort"].exists() {
            let resortJson:JSON = json["resort"]
            self.resort = Resort(json: resortJson)
        }
        
        if json["unit"].exists() {
            let unitJson:JSON = json["unit"]
            self.unit = InventoryUnit(json:unitJson)
        }
        
        self.pointsMatrix = json["pointsMatrix"].boolValue
        self.blackedOut = json["blackedOut"].boolValue
        self.bulkAssignment = json["bulkAssignment"].boolValue
        self.memberUnitLocked = json["memberUnitLocked"].boolValue
        self.payback = json["payback"].boolValue
        self.waitList = json["waitlist"].boolValue
        self.waitListNumber = json["waitListNumber"].intValue
        
        if json["reservationAttributes"].exists() {
            let reservationAttributesJsonArray:[JSON] = json["reservationAttributes"].arrayValue
            self.reservationAttributes = reservationAttributesJsonArray.map { $0.string! }
        }
        
        if json["virtualWeekActions"].exists() {
            let virtualWeekActionsJsonArray:[JSON] = json["virtualWeekActions"].arrayValue
            self.virtualWeekActions = virtualWeekActionsJsonArray.map { $0.string! }
        }

        if json["promotion"].exists() {
            let promotionJson:JSON = json["promotion"]
            self.promotion = Promotion(json:promotionJson)
        }
    }

}
