//
//  Currency.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/17/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

open class Currency {
    
    open var code : String = ""
    open var symbol : String = ""
    open var description : String = ""
    
    public init() {
    }
    
    public init(_ code: String, _ symbol: String, _ description: String) {
        self.code = code
        self.symbol = symbol
        self.description = description
    }
    
}
