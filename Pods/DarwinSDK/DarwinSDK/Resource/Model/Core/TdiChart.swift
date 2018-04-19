//
//  TdiChart.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 4/11/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class TdiChart {
    
    open var url : String?
  
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.url = json["url"].string ?? ""
    }
    
}
