//
//  InsuranceError.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class InsuranceError {
    
    open var code : String?
    open var description : String?
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.code = json["code"].string ?? ""
        self.description = json["description"].string ?? ""
    }
    
}

