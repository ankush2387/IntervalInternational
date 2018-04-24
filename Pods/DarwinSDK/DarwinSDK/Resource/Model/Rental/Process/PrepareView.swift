//
//  PrepareView.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class PrepareView {
    
    open lazy var actions = [String]() // ProcessAction
    open var destination : RentalDestination?
    open lazy var promoCodes = [String]()
    open var fees : RentalFees?
    open var forceRenewals : ForceRenewals?
    open var accommodationCertificateNumber: Int?
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()

        if json["actions"].exists() {
            let actionsArray:[JSON] = json["actions"].arrayValue
            self.actions = actionsArray.map { $0.string! }
        }
        
        if json["destination"].exists() {
            let destinationJson:JSON = json["destination"]
            self.destination = RentalDestination(json:destinationJson)
        }
        
        if json["promoCodes"].exists() {
            let promoCodesArray:[JSON] = json["promoCodes"].arrayValue
            self.promoCodes = promoCodesArray.map { $0.string! }
        }
 
        if json["fees"].exists() {
            self.fees = RentalFees(json: json["fees"])
        }
        
        if json["forceRenewals"].exists() {
            self.forceRenewals = ForceRenewals(json: json["forceRenewals"])
        }
        
        if json["accommodationCertificateNumber"].exists() {
            self.accommodationCertificateNumber = json["accommodationCertificateNumber"].intValue
        }
    }
    
}
