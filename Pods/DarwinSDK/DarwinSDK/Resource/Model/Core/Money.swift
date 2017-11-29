//
//  Money
//  DarwinSDK
//
//  Created by Frank Nogueiras on 3/7/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Money {
    
    open var currencyCode : String?
    open var amount : Float = 0.0
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.currencyCode = json["currency"].string ?? "USD"
        
        if json["amount"].exists() && json["amount"].float != nil {
            self.amount = json["amount"].floatValue
        }
    }
    
}
