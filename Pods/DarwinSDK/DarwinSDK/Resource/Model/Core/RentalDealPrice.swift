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

	open var lowest: Float?
    open var currencySymbol: String?
    open var checkInDate: Date?
    
    public init(){
    }
	
    public convenience init(json:JSON){
        self.init()
        
        self.lowest = json["lowest"].floatValue
        self.currencySymbol = json["currencySymbol"].string ?? ""
        
        if let dateStr = json["checkInDate"].string {
            self.checkInDate = dateStr.dateFromShortFormat()
        }
    }
}
