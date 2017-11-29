//
//  ExchangeProcessContinueToPayRequest.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeProcessContinueToPayRequest {
    
    open var acceptTermsAndConditions : Bool?
    open var acknowledgeAndAgreeResortFees : Bool?
    open var creditCard : Creditcard?
    open var saveCardIndicator : Bool?
    open var confirmationDelivery : ConfirmationDelivery?
    
    public init() {
    }

    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["form"] = self.formToDictionary() as AnyObject?
        return dictionary
    }
    
    private func formToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        if (acceptTermsAndConditions != nil) {
            dictionary["acceptTermsAndConditions"] = self.acceptTermsAndConditions as AnyObject?
        }
        if (acknowledgeAndAgreeResortFees != nil) {
            dictionary["acknowledgeAndAgreeResortFees"] = self.acknowledgeAndAgreeResortFees as AnyObject?
        }
        dictionary["creditCard"] = self.creditCardToDictionary() as AnyObject?
        if (saveCardIndicator != nil) {
            dictionary["saveCardIndicator"] = self.saveCardIndicator as AnyObject?
        }
        dictionary["confirmationDelivery"] = self.confirmationDeliveryToDictionary() as AnyObject?
        return dictionary
    }
    
    private func creditCardToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        if (self.creditCard?.creditcardId)! > 0 {
            dictionary["id"] = self.creditCard?.creditcardId as AnyObject?
        } else {
            dictionary["type"] = self.creditCard?.typeCode as AnyObject?
            dictionary["cardHolderName"] = self.creditCard?.cardHolderName as AnyObject?
            dictionary["cardNumber"] = self.creditCard?.cardNumber as AnyObject?
            dictionary["expirationDate"] = self.creditCard?.expirationDate! as AnyObject?
            dictionary["preferredCardIndicator"] = self.creditCard?.preferredCardIndicator as AnyObject?
            dictionary["saveCardIndicator"] = self.creditCard?.saveCardIndicator as AnyObject?
            dictionary["autoRenew"] = self.creditCard?.autoRenew as AnyObject?
            dictionary["billingAddress"] = self.billingAddressToDictionary() as AnyObject?
        }
        dictionary["cvv"] = self.creditCard?.cvv as AnyObject?
        return dictionary
    }
    
    private func confirmationDeliveryToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["emailAddress"] = self.confirmationDelivery?.emailAddress as AnyObject?
        dictionary["updateProfile"] = self.confirmationDelivery?.updateProfile as AnyObject?
        return dictionary
    }
    
    private func billingAddressToDictionary() -> Dictionary<String, AnyObject> {
        var addressLinesArray = Array<AnyObject>()
        for addressLine in (self.creditCard?.billingAddress?.addressLines)! {
            addressLinesArray.append(addressLine as AnyObject)
        }
        
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["addressLines"] = addressLinesArray as AnyObject?
        dictionary["cityName"] = self.creditCard?.billingAddress?.cityName as AnyObject?
        dictionary["territoryCode"] = self.creditCard?.billingAddress?.territoryCode as AnyObject?
        dictionary["countryCode"] = self.creditCard?.billingAddress?.countryCode as AnyObject?
        dictionary["postalCode"] = self.creditCard?.billingAddress?.postalCode as AnyObject?
        return dictionary
    }
    
}
