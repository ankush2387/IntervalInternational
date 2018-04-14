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
    }

    open func postalAddresAsString() -> String {
        return [cityName, territoryCode, countryCode].flatMap { $0 }.joined(separator: ", ")
    }
    
}
