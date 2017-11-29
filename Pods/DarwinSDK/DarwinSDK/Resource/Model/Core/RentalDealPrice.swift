//
//  RentalDealPrice.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 04/24/17.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalDealPrice {

	open var fromPrice : Float = 0.0
    open var currencySymbol : String?
    
    public init(){
    }
	
    public convenience init(json:JSON){
        self.init()
        
        self.currencySymbol = json["currencySymbol"].string ?? ""
        self.fromPrice = json["fromPrice"].floatValue
    }
}
