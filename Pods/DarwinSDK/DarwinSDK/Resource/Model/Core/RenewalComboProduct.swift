//
//  RenewalComboProduct.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 9/20/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RenewalComboProduct {
    
    open lazy var renewalComboProducts = [Renewal]()
    
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        if json["renewalComboProducts"].exists() {
            let renewalComboProductsArray:[JSON] = json["renewalComboProducts"].arrayValue
            self.renewalComboProducts = renewalComboProductsArray.map { Renewal(json:$0) }
        }
    }
    
}

