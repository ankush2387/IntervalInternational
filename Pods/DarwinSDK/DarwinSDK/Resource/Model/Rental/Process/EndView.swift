//
//  EndView.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class EndView {
    
    open var fees : RentalFees?
    
    public init() {
    }
    
    public init(json:JSON) {
        if json["fees"].exists() {
            self.fees = RentalFees.init(json: json["fees"])
        }
    }

}
