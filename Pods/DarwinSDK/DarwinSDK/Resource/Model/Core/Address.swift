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

    open func postalAddresAsString() -> String {
        var s = ""

        if let cityName = self.cityName {
           s += cityName
        }
        
        if let territoryCode = self.territoryCode {
            if !s.isEmpty {
                s += ", "
            }
            s += territoryCode
        }

        if let countryCode = self.countryCode {
            if !s.isEmpty {
                s += ", "
            }
            s += countryCode
        }
        
        return s
    }
    
}
