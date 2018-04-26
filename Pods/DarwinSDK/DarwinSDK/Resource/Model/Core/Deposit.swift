//
//  Deposit.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/15/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Deposit {

    open var relinquishmentId : String?
    open lazy var actions = [String]() // AvailableWeekAction
    open var exchangeNumber : Int?
    open var requestType : String? // RequestType
    open var relinquishmentYear : Int?
    open var exchangeStatus : String? // ExchangeStatus
    open var weekNumber : String? // WeekNumber
    open var pointsProgramCode : String? // PointsProgramCode
    open var programPoints : Int? = 0
    open var checkInDate : String?
    open var checkOutDate : String?
    open var expirationDate : String?
    open var resort : Resort?
    open var unit : InventoryUnit?
    open var supplementalWeek : Bool? = false
    open var waitList : Bool? = false
    open var waitListNumber : Int = 0
    open var insurancePurchase : String?
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

        if json["exchangeNumber"].exists() {
            self.exchangeNumber = json["exchangeNumber"].intValue
        }

        self.requestType = json["type"].string ?? ""
        
        if json["relinquishmentYear"].exists() {
            self.relinquishmentYear = json["relinquishmentYear"].intValue
        }
        
        self.exchangeStatus = json["exchangeStatus"].string ?? ""
        self.weekNumber = json["weekNumber"].string ?? ""
        self.pointsProgramCode = json["pointsProgramCode"].string ?? ""
        self.programPoints = json["programPoints"].intValue
        self.checkInDate = json["checkInDate"].string ?? ""
        self.checkOutDate = json["checkOutDate"].string ?? ""
        self.expirationDate = json["expirationDate"].string ?? ""
      
        if json["resort"].exists() {
            let resortJson:JSON = json["resort"]
            self.resort = Resort(json: resortJson)
        }

        if json["unit"].exists() {
            let unitJson:JSON = json["unit"]
            self.unit = InventoryUnit(json:unitJson)
        }

        self.supplementalWeek = json["supplementalWeek"].boolValue
        self.waitList = json["waitlist"].boolValue
        self.waitListNumber = json["waitListNumber"].intValue
        self.insurancePurchase = json["insurancePurchase"].string ?? ""
       
        if json["virtualWeekActions"].exists() {
            let virtualWeekActionsJsonArray:[JSON] = json["virtualWeekActions"].arrayValue
            self.virtualWeekActions = virtualWeekActionsJsonArray.map { $0.string! }
        }
        
        if json["promotion"].exists() {
            let promotionJson:JSON = json["promotion"]
            self.promotion = Promotion(json:promotionJson)
        }
    }
    
    open func getDaysUntilExpirationDate() -> Int {
        if let expDate = self.expirationDate {
            let today = Date()
            return today.daysBetween(to: expDate.dateFromShortFormat()!)
        }
        return -1 // Expired
    }

}
