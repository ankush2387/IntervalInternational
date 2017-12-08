//
//  AccommodationCertificate.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AccommodationCertificate {
    
    open var certificateNumber : Int?
    open var certificateType : String? // CertificateType
    open var certificateStatus : String? // CertificateStatus
    open var issueDate : String?
    open var expirationDate : String?
    open var daysOut : Int?
    open var resort : Resort?
    open var unit : InventoryUnit?
    open var travelWindow : TravelWindow?
    open var extendable : Bool?
    open lazy var actions = [String]() // CertificateAction

    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()

        if json["certificateNumber"].exists() {
            self.certificateNumber = json["certificateNumber"].intValue
        }
        
        self.certificateType = json["certificateType"].string ?? ""
        self.certificateStatus = json["certificateStatus"].string ?? ""
        self.issueDate = json["issueDate"].string ?? ""
        self.expirationDate = json["expirationDate"].string ?? ""
        
        if json["daysOut"].exists() {
            self.daysOut = json["daysOut"].intValue
        }
        
        if json["resort"].exists() {
            let resortJson:JSON = json["resort"]
            self.resort = Resort(summaryJSON:resortJson)
        }
        
        if json["unit"].exists() {
            let unitJson:JSON = json["unit"]
            self.unit = InventoryUnit(json:unitJson)
        }
        
        if json["travelWindow"].exists() {
            let travelWindowJson:JSON = json["travelWindow"]
            self.travelWindow = TravelWindow(json:travelWindowJson)
        }
        
        if json["extendable"].exists() {
            self.extendable = json["extendable"].boolValue
        }
        
        if json["actions"].exists() {
            let actionsJsonArray:[JSON] = json["actions"].arrayValue
            self.actions = actionsJsonArray.map { $0.string! }
        }
    }
    
    open func getDaysUntilExpirationDate() -> Int {
        if let expDate = self.expirationDate {
            let today = Date()
            return today.daysBetween(to: expDate.dateFromShortFormat()!)
        }
        return -1 // Expired
    }
}

