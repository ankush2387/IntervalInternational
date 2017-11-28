//
//  AncillaryProducts.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AncillaryProducts {
    
    open var guestCertificate : GuestCertificate?
    open var insurance : Insurance?
    open var eplus : Eplus?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        if json["guestCertificate"].exists() {
            let guestCertificateJson:JSON = json["guestCertificate"]
            self.guestCertificate = GuestCertificate(json:guestCertificateJson)
        }
        
        if json["insurance"].exists() {
            let insuranceJson:JSON = json["insurance"]
            self.insurance = Insurance(json:insuranceJson)
        }

        if json["eplus"].exists() {
            let eplusJson:JSON = json["eplus"]
            self.eplus = Eplus(json:eplusJson)
        }
    }
    
}

