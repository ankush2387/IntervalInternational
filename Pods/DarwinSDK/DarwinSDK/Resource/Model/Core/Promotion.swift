//
//  Promotion.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Promotion {
    
    open var rewardType : String?
    open var rewardOrPromo : String?
    open var isPlatinumEscape : Bool = false
    open var amount : Float = 0.0
    open var offerType : String?
    open var offerName : String?
    open var offerContentId : Int = 0
    open var offerContentFragment : String?
   
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.rewardType = json["rewardType"].string ?? ""
        self.rewardOrPromo = json["rewardOrPromo"].string ?? ""
        self.isPlatinumEscape = json["isPlatinumEscape"].boolValue
        self.amount = json["amount"].floatValue
        self.offerType = json["offerType"].string ?? ""
        self.offerName = json["offerName"].string ?? ""
        
        if json["offerContent"].exists() {
            let offerContent:JSON = json["offerContent"]
            self.offerContentId = offerContent["id"].intValue
            self.offerContentFragment = offerContent["fragment"].string ?? ""
        }
    }
    
}

