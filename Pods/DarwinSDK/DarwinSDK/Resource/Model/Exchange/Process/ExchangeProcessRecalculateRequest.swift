//
//  ExchangeProcessRecalculateRequest.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeProcessRecalculateRequest {
    
    open var fees : ExchangeFees?
    
    public init() {
    }
    
    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["form"] = self.formToDictionary() as AnyObject?
        return dictionary
    }
    
    private func formToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        var feesDictionary = Dictionary<String, AnyObject>()
        
        if self.fees?.shopExchange?.selectedOfferName != nil {
            dictionary["shop"] = self.shopExchangeToDictionary() as AnyObject?
        }
        if self.fees?.insurance?.selected != nil {
            dictionary["insurance"] = self.insuranceToDictionary() as AnyObject?
        }
        if self.fees?.eplus?.selected != nil {
            dictionary["ePlus"] = self.eplusToDictionary() as AnyObject?
        }
        
        feesDictionary["fees"] = dictionary as AnyObject?
        
        return feesDictionary
    }
    
    private func shopExchangeToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["selectedOfferName"] = self.fees?.shopExchange?.selectedOfferName as AnyObject?
        return dictionary
    }
    
    private func insuranceToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["selected"] = self.fees?.insurance?.selected as AnyObject?
        return dictionary
    }
    
    private func eplusToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["selected"] = self.fees?.eplus?.selected as AnyObject?
        return dictionary
    }
}
