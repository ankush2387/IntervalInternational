//
//  Cabin.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Cabin {
    
    open var number : String?
    open var details : String?
    open var sailingDate : String?
    open var returnDate : String?
    open var travelParty : TravelParty?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.number = json["number"].string ?? ""
        self.details = json["details"].string ?? ""
        self.sailingDate = json["sailingDate"].string ?? ""
        self.returnDate = json["returnDate"].string ?? ""
        
        if json["travelParty"].exists() {
            let travelPartyJson:JSON = json["travelParty"]
            self.travelParty = TravelParty(json:travelPartyJson)
        }
    }
    
}

