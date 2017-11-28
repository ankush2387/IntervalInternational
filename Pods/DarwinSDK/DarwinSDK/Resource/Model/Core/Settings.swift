//
//  Settings.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 8/18/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Settings {

    open var vacationSearch : VacationSearchSettings?
    open var android : AppSettings?
    open var ios : AppSettings?
 
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        if json["vacationSearch"].exists() {
            self.vacationSearch = VacationSearchSettings(json: json["vacationSearch"])
        }
        
        if json["android"].exists() {
            self.android = AppSettings(json: json["android"])
        }
        
        if json["ios"].exists() {
            self.ios = AppSettings(json: json["ios"])
        }
    }
    
}
