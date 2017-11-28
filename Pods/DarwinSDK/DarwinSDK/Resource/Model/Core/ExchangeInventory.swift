//
//  ExchangeInventory.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 6/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeInventory {
    
    open var checkInDate : String?
    open var checkOutDate : String?
    open var generalUnitSizeUpgradeMessage : Bool = false
    open var matchDestination : Bool = false
    open var childrenAllowed : Bool = false
    open lazy var buckets = [ExchangeBucket]()
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.checkInDate = json["checkInDate"].string ?? ""
        self.checkOutDate = json["checkOutDate"].string ?? ""
        self.generalUnitSizeUpgradeMessage = json["generalUnitSizeUpgradeMessage"].boolValue
        self.matchDestination = json["matchDestination"].boolValue
        self.childrenAllowed = json["childrenAllowed"].boolValue
        
        if json["buckets"].exists() {
            let bucketsArray:[JSON] = json["buckets"].arrayValue
            self.buckets = bucketsArray.map { ExchangeBucket(json:$0) }
        }
    }
}
