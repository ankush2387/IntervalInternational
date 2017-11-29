//
//  RecapView.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RecapView {
    
    open lazy var actions = [String]() // ProcessAction
    open lazy var promoCodes = [String]()
    open lazy var allowedCurrencies = [String]()
    open lazy var allowedCreditCardTypes = [AllowedCreditCardType]()
    open var fees : RentalFees?
    
    public init() {
    }
    
    public init(json:JSON) {
        if json["actions"].exists() {
            let actionsArray:[JSON] = json["actions"].arrayValue
            self.actions = actionsArray.map { $0.string! }
        }
        
        if json["promoCodes"].exists() {
            let promoCodesArray:[JSON] = json["promoCodes"].arrayValue
            self.promoCodes = promoCodesArray.map { $0.string! }
        }
        
        if json["allowedCurrencies"].exists() {
            let allowedCurrenciesArray:[JSON] = json["allowedCurrencies"].arrayValue
            self.allowedCurrencies = allowedCurrenciesArray.map { $0.string! }
        }
        
        if json["allowedCreditCardTypes"].exists() {
            let allowedCreditCardTypesArray:[JSON] = json["allowedCreditCardTypes"].arrayValue
            self.allowedCreditCardTypes = allowedCreditCardTypesArray.map { AllowedCreditCardType(json:$0) }
        }

        if json["fees"].exists() {
            self.fees = RentalFees(json: json["fees"])
        }
    }
    
}
