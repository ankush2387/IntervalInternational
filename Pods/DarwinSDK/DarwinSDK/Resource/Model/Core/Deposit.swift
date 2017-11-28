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
    open var exchangeNumber : Int64?
    open var exchangeStatus : String? // ExchangeStatus
    open var weekNumber : String?
    open var requestType : String?
    open var relinquishmentYear : Int?
    open var resort : Resort?
    open var unit : InventoryUnit?
    open var checkInDate : String?
    open var checkOutDate : String?
    open var expirationDate : String?
    open var waitListNumber : String?
    open var insurancePurchase : String?
    open var blackedOut : Bool? = false
    open var supplementalWeek : Bool? = false

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
            self.exchangeNumber = json["exchangeNumber"].int64Value
        }

        self.exchangeStatus = json["exchangeStatus"].string ?? ""
        self.weekNumber = json["weekNumber"].string ?? ""
        self.relinquishmentYear = json["relinquishmentYear"].intValue

        if json["resort"].exists() {
            let resortJson:JSON = json["resort"]
            self.resort = Resort(detailJSON:resortJson)
        }

        if json["unit"].exists() {
            let unitJson:JSON = json["unit"]
            self.unit = InventoryUnit(json:unitJson)
        }

        self.checkInDate = json["checkInDate"].string ?? ""
        self.checkOutDate = json["checkOutDate"].string ?? ""
        self.expirationDate = json["expirationDate"].string ?? ""
        self.requestType = json["requestType"].string ?? ""
        self.waitListNumber = json["waitListNumber"].string ?? ""
        self.insurancePurchase = json["insurancePurchase"].string ?? ""
        self.blackedOut = json["blackedOut"].boolValue
        self.supplementalWeek = json["supplementalWeek"].boolValue
    }

}
