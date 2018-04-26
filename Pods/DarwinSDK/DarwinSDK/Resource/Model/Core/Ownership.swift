//
//  Ownership.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/7/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Ownership {
    
	open var resort : Resort?
    open var unit : InventoryUnit?
    open var weekNumber : String?
	
	public init() {
	}
	
    public init(json:JSON) {
        if json["resort"].exists() {
            let resortJson:JSON = json["resort"]
            self.resort = Resort(json: resortJson)
        }
        
        if json["unit"].exists() {
            let unitJson:JSON = json["unit"]
            self.unit = InventoryUnit(json:unitJson)
        }
        
        self.weekNumber = json["weekNumber"].string ?? ""
    }
    
}
