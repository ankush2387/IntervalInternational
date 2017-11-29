//
//  AccommodationCertificateSummary.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/26/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AccommodationCertificateSummary {
    
    open lazy var header = [String]()
    open lazy var footer = [String]()
    open var restrictedArea : RestrictedArea?
    open var restrictedResort : RestrictedResort?

    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        if json["header"].exists() {
            let headerJsonArray:[JSON] = json["header"].arrayValue
            self.header = headerJsonArray.map { $0.string! }
        }
        
        if json["footer"].exists() {
            let footerJsonArray:[JSON] = json["footer"].arrayValue
            self.footer = footerJsonArray.map { $0.string! }
        }
        
        if json["area"].exists() {
            let restrictedAreaJson:JSON = json["area"]
            self.restrictedArea = RestrictedArea(json:restrictedAreaJson)
        }
        
        if json["resort"].exists() {
            let restrictedResortJson:JSON = json["resort"]
            self.restrictedResort = RestrictedResort(json:restrictedResortJson)
        }
    }
}
