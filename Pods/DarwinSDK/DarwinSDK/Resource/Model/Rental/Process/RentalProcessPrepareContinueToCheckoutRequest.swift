//
//  RentalProcessPrepareContinueToCheckoutRequest.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalProcessPrepareContinueToCheckoutRequest {

    open var guest : Guest?
    open lazy var promoCodes = [String]()
    open lazy var renewals = [Renewal]()

    public init() {
    }

    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["form"] = self.formToDictionary() as AnyObject?
        return dictionary
    }
    
    private func formToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()

        if (guest != nil) {
            dictionary["guest"] = self.guest?.toDictionary() as AnyObject?
        }

        if (promoCodes.count > 0) {
            dictionary["promoCodes"] = self.promoCodes as AnyObject?
        }

        if (renewals.count > 0) {
            var renewalsArray = Array<AnyObject>()
            for renewal in renewals {
                renewalsArray.append(self.renewalToDictionary(renewal: renewal) as AnyObject)
            }
            dictionary["renewals"] = renewalsArray as AnyObject?
        }
        return dictionary
    }

    private func renewalToDictionary(renewal : Renewal) -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["id"] = renewal.id as AnyObject?
        return dictionary
    }

}



