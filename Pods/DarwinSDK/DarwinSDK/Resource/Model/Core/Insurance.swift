//
//  Insurance.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Insurance {
    
    open var price : Float = 0.0
    open var insuranceOfferHTML : String?
    open var selected : Bool?
    open var policyNumber : String?
    open var status : String?
    open var error : InsuranceError?
    open var providerPhoneNumber : String?
    open var activeChoise : String? // ActiveChoise
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.price = json["price"].floatValue
        self.insuranceOfferHTML = json["insuranceOfferHTML"].string ?? ""

        if let value = json["selected"].bool {
            self.selected = value
        }
        
        self.policyNumber = json["policyNumber"].string ?? ""
        self.status = json["status"].string ?? ""
        
        if json["error"].exists() {
            self.error = InsuranceError.init(json: json["error"])
        }
        
        self.providerPhoneNumber = json["providerPhoneNumber"].string ?? ""
        self.activeChoise = json["activeChoise"].string ?? ""
    }
    
}
