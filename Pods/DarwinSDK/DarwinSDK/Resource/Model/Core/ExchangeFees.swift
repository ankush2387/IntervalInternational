//
//  ExchangeFees.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 6/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeFees {
    
    // open var exchangeTransactionType : String? // ExchangeTransactionType
    open var memberTier : String?
    open var currencyCode : String?
    open var total : Float = 0.0
    open var shopExchange : ShopExchange?
    open var guestCertificate : GuestCertificate?
    open var insurance : Insurance?
    open var eplus : Eplus?
    open var unitSizeUpgrade : UnitSizeUpgrade?
    open lazy var renewals = [Renewal]()


    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.memberTier = json["memberTier"].string ?? ""
        self.currencyCode = json["currencyCode"].string ?? ""
        self.total = json["total"].floatValue
        
        if json["shop"].exists() {
            self.shopExchange = ShopExchange(json: json["shop"])
        }
        
        if json["guestCertificate"].exists() {
            self.guestCertificate = GuestCertificate(json: json["guestCertificate"])
        }
        
        if json["insurance"].exists() {
            self.insurance = Insurance(json: json["insurance"])
        }
        
        if json["ePlus"].exists() {
            self.eplus = Eplus(json: json["ePlus"])
        }
        
        if json["unitSize"].exists() {
            self.unitSizeUpgrade = UnitSizeUpgrade(json: json["unitSize"])
        }
        
        if json["renewals"].exists() {
            let renewalsArrary:[JSON] = json["renewals"].arrayValue
            self.renewals = renewalsArrary.map { Renewal(json:$0) }
        }
    }
    
}
