//
//  RentalProcessRecapRecalculateUsingCardPromotionRequest.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalProcessRecapRecalculateRequest {
    
    open var fees : RentalFees?
    
    public init() {
    }
    
    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["form"] = self.formToDictionary() as AnyObject?
        return dictionary
    }
    
    private func formToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        
        if self.fees?.rental?.selectedOfferName != nil {
            dictionary["fees"] = self.rentalFeeToDictionary() as AnyObject?
        }
        if self.fees?.insurance?.selected != nil {
            dictionary["fees"] = self.insuranceFeeToDictionary() as AnyObject?
        }
        
        return dictionary
    }
    
    private func rentalFeeToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["rental"] = self.rentalToDictionary() as AnyObject?
        return dictionary
    }
    
    private func rentalToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["selectedOfferName"] = self.fees?.rental?.selectedOfferName as AnyObject?
        return dictionary
    }
    
    private func insuranceFeeToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["insurance"] = self.insuranceToDictionary() as AnyObject?
        return dictionary
    }

    private func insuranceToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["selected"] = self.fees?.insurance?.selected as AnyObject?
        return dictionary
    }
    
}
