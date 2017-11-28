//
//  Product.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/7/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Product {
    
	open var productCode : String?
	open var productName : String?
	open var expirationDate : Date?
	open var billingEntity : String?
	open var coreProduct : Bool = false
	open var autoRenew : Bool = false
    open var highestTier : Bool = false
	
	public init() {
	}
	
	public init(json:JSON) {
		self.productCode = json["productCode"].string
		self.productName = json["productName"].string
        self.billingEntity = json["billingEntity"].string
		
		if let dateStr = json["expirationDate"].string {
			self.expirationDate = dateStr.dateFromLongFormat()
		}

		self.coreProduct = json["coreProduct"].boolValue
		self.autoRenew = json["autoRenew"].boolValue
        self.highestTier = json["highestTier"].boolValue
	}
    
}
