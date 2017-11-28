//
//  TravelWindow.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class TravelWindow {
    
    open var fromDate : String?
    open var toDate : String?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        if let value = json["fromDate"].string {
            self.fromDate = value
        } else if let value = json["from"].string {
            self.fromDate = value
        }
        
        if let value = json["toDate"].string {
            self.toDate = value
        } else if let value = json["to"].string {
            self.toDate = value
        }
    }
    
}
