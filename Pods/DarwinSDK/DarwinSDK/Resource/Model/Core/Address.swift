//
//  Address.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 12/14/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Address {
    
    open var addressId : Int64
    open var addressType : String?
    open lazy var addressLines = [String]()
    open var cityName : String?
    open var territoryCode : String?
    open var countryCode : String?
    open var postalCode : String?
    open var status : String?
    open var statusChangeReason : String?
    open var enterpriseCode : String?

    public init() {
        self.addressId = 0
    }

    public init(json:JSON) {
        self.addressId = json["id"].int64Value
        self.addressType = json["type"].string

        if json["addressLines"].exists() {
            let addressLinesJsonArray:[JSON] = json["addressLines"].arrayValue
            self.addressLines = addressLinesJsonArray.map { $0.string! }
        }
        
        self.cityName = json["cityName"].string
        self.territoryCode = json["territoryCode"].string
        self.countryCode = json["countryCode"].string
        self.postalCode = json["postalCode"].string
        self.status = json["status"].string
        self.statusChangeReason = json["statusChangeReason"].string
        self.enterpriseCode = json["enterpriseCode"].string
    }
    
    open func postalAddressString() -> String {
        var sep = false
        var s = ""
        
        if (self.addressLines.count > 0 && self.addressLines[0].characters.count > 0) {
            s += self.addressLines[0]
            sep = true
        }
        
        if (self.addressLines.count > 1 && self.addressLines[1].characters.count > 0) {
            s += (sep == true ? ", " : "")
            s += self.addressLines[1]
            sep = true
        }

        if (self.addressLines.count > 2 && self.addressLines[2].characters.count > 0) {
            s += (sep == true ? ", " : "")
            s += self.addressLines[2]
            sep = true
        }

        if (self.cityName?.characters.count)! > 0 {
            s += (sep == true ? ", " : "")
            s += self.cityName!
            sep = true
        }

        if (self.territoryCode?.characters.count)! > 0 {
            s += (sep == true ? ", " : "")
            s += self.territoryCode!
            sep = true
        }

        if (self.postalCode?.characters.count)! > 0 {
            s += (sep == true ? " " : "")
            s += self.postalCode!
            sep = true
        }
        
        if (self.countryCode?.characters.count)! > 0 {
            s += (sep == true ? ", " : "")
            s += self.countryCode!
            sep = true
        }
    
        return s
    }
    
}
