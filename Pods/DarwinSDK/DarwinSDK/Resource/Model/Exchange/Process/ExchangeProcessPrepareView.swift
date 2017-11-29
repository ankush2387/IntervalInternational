//
//  ExchangeProcessPrepareView.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeProcessPrepareView {
    
    open lazy var actions = [String]() // ProcessAction
    open lazy var promoCodes = [String]()
    open var relinquishment : ExchangeRelinquishment?
    open var destination : ExchangeDestination?
    open var fees : ExchangeFees?
    open var forceRenewals : ForceRenewals?
    open var adviseQrrDowntrade : Bool? = false
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()

        if json["actions"].exists() {
            let actionsArray:[JSON] = json["actions"].arrayValue
            self.actions = actionsArray.map { $0.string! }
        }
        
        if json["promoCodes"].exists() {
            let promoCodesArray:[JSON] = json["promoCodes"].arrayValue
            self.promoCodes = promoCodesArray.map { $0.string! }
        }
        
        if json["destination"].exists() {
            let destinationJson:JSON = json["destination"]
            self.destination = ExchangeDestination(json:destinationJson)
        }
        
        if json["relinquishment"].exists() {
            let relinquishmentJson:JSON = json["relinquishment"]
            self.relinquishment = ExchangeRelinquishment(json:relinquishmentJson)
        }
        
        if json["fees"].exists() {
            self.fees = ExchangeFees(json: json["fees"])
        }
        
        if json["forceRenewals"].exists() {
            self.forceRenewals = ForceRenewals(json: json["forceRenewals"])
        }
        
        self.adviseQrrDowntrade = json["adviseQrrDowntrade"].boolValue
    }
    
}
