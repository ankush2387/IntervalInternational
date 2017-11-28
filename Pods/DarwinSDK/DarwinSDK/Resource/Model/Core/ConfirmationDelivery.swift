//
//  ConfirmationDelivery.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ConfirmationDelivery {
    
    open var emailAddress : String?
    open var updateProfile : Bool = false
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.emailAddress = json["emailAddress"].string ?? ""
        self.updateProfile = json["updateProfile"].boolValue
    }
    
}

