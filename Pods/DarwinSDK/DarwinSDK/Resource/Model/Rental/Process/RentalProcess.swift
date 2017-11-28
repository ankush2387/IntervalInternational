//
//  RentalProcess.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalProcess {
    
    let HOLD_MAX_TIME_IN_MILLIS = 17
    
    open lazy var actions = [String]() // ProcessAction
    open var processId : Int = 0
    open var currentStep : ProcessStep?
    // Prepare View payload
    open var resort : Resort?
    open var unit : InventoryUnit?
    open var forceRenewals : ForceRenewals?
    open var termsAndConditions : String?
    open var accommCertificateNumber : String?
    // Recap View payload
    open lazy var allowedCurrencies = [String]()
    open lazy var allowedCreditCardTypes = [AllowedCreditCardType]()
    // Both (Prepare & Recap) View payload
    open var fees : RentalFees?
    open lazy var promoCodes = [String]()
    
    //open var renewalOptions : RenewalOptions?
    open var holdUnitStartTimeInMillis : Int = 0
    
    public init() {
    }
    
}
