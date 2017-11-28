//
//  GuestCertificate.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class GuestCertificate {
    
    open lazy var prices = [InventoryPrice]()
    open var guest : Guest?
    open var guestCertificatePrice : InventoryPrice?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        if json["prices"].exists() {
            let pricesArrary:[JSON] = json["prices"].arrayValue
            self.prices = pricesArrary.map { InventoryPrice(json:$0) }
        }
        
        if json["guest"].exists() {
            self.guest = Guest.init(json: json["guest"])
        }
   
        self.guestCertificatePrice = InventoryPrice()
        self.guestCertificatePrice?.price = json["price"].float ?? 0.0
        self.guestCertificatePrice?.tax = json["tax"].float ?? 0.0
        if json["taxBreakdown"].exists() {
            let taxBreakdownArrary:[JSON] = json["taxBreakdown"].arrayValue
            self.guestCertificatePrice?.taxBreakdown = taxBreakdownArrary.map { InventoryPriceTax(json:$0) }
        }
    }
    
}
