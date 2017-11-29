//
//  ExchangeProcessApplyPromoCodeRequest.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeProcessApplyPromoCodeRequest {
    
    open lazy var promoCodes = [String]()
    
    public init() {
    }
    
    public convenience init(promoCodes:[String]) {
        self.init()
        
        self.promoCodes = promoCodes
    }
    
    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["form"] = self.formToDictionary() as AnyObject?
        return dictionary
    }
    
    private func formToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["promoCodes"] = self.promoCodes as AnyObject?
        return dictionary
    }
    
}


