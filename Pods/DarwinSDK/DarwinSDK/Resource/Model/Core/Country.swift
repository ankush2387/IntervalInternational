//
//  Country.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/4/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Country {
    
	open var countryCode : String?
	open var countryName : String?
    open var phoneCode : Int?

	public init() {
	}

    public convenience init(code:String?, name:String?) {
        self.init()
        
        self.countryCode = code
        self.countryName = name
    }
	
	public convenience init(json:JSON) {
        self.init()
        
		self.countryCode = json["code"].string
		self.countryName = json["name"].string
        self.phoneCode = json["phoneCode"].intValue
	}
    
}
