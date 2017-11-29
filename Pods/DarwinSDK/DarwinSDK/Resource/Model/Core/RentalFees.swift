//
//  RentalFees.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalFees {
    
    open var memberTier : String?
    open var currencyCode : String?
    open var total : Float = 0.0
    open var rental : Rental?
    open var guestCertificate : GuestCertificate?
    open var insurance : Insurance?
    open lazy var renewals = [Renewal]()
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.memberTier = json["memberTier"].string ?? ""
        self.currencyCode = json["currencyCode"].string ?? ""
        self.total = json["total"].floatValue
        
        if json["rental"].exists() {
            self.rental = Rental.init(json: json["rental"])
        }
        
        if json["guestCertificate"].exists() {
            self.guestCertificate = GuestCertificate(json: json["guestCertificate"])
        }
        
        if json["insurance"].exists() {
            self.insurance = Insurance(json: json["insurance"])
        }
        
        if json["renewals"].exists() {
            let renewalsArrary:[JSON] = json["renewals"].arrayValue
            self.renewals = renewalsArrary.map { Renewal(json:$0) }
        }
    }
    
}
