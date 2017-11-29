//
//  ForceRenewals.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ForceRenewals {
    
    open var currencyCode : String?
    open lazy var productEligibility = [ProductEligibility]()
    open lazy var products = [Renewal]()
    open lazy var comboProducts = [RenewalComboProduct]()
    open lazy var crossSelling = [Renewal]()

    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.currencyCode = json["currencyCode"].string ?? ""
        
        if json["productEligibility"].exists() {
            let productEligibilityArray:[JSON] = json["productEligibility"].arrayValue
            self.productEligibility = productEligibilityArray.map { ProductEligibility(json:$0) }
        }
        
        if json["products"].exists() {
            let productsArray:[JSON] = json["products"].arrayValue
            self.products = productsArray.map { Renewal(json:$0) }
        }
        
        if json["comboProducts"].exists() {
            let comboProductsArray:[JSON] = json["comboProducts"].arrayValue
            self.comboProducts = comboProductsArray.map { RenewalComboProduct(json:$0) }
        }
        
        if json["crossSelling"].exists() {
            let crossSellingArray:[JSON] = json["crossSelling"].arrayValue
            self.crossSelling = crossSellingArray.map { Renewal(json:$0) }
        }
    }
    
}
