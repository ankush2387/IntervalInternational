//
//  RentalProcessStartRequest.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalProcessStartRequest {
    
    open var resort : Resort?
    open var unit : InventoryUnit?
    
    public init() {
    }
    
    public convenience init(resortCode:String?, checkInDate:String?, checkOutDate:String?, unitSize:UnitSize?, kitchenType:KitchenType?) {
        self.init()
        
        self.resort = Resort(resortCode: resortCode)
        self.unit = InventoryUnit(checkInDate: checkInDate, checkOutDate: checkOutDate, unitSize: unitSize, kitchenType: kitchenType)
    }

    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["form"] = self.formToDictionary() as AnyObject?
        return dictionary
    }
    
    private func formToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["resort"] = self.resortToDictionary() as AnyObject?
        dictionary["unit"] = self.unitToDictionary() as AnyObject?
        return dictionary
    }
    
    private func resortToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["code"] = resort?.resortCode! as AnyObject?
        return dictionary
    }

    private func unitToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        //dictionary["checkInDate"] = unit?.checkInDate!.stringWithShortFormatForJSON() as AnyObject?
        //dictionary["checkOutDate"] = unit?.checkOutDate!.stringWithShortFormatForJSON() as AnyObject?
        dictionary["checkInDate"] = unit?.checkInDate! as AnyObject?
        dictionary["checkOutDate"] = unit?.checkOutDate! as AnyObject?
        dictionary["unitSize"] = unit?.unitSize! as AnyObject?
        dictionary["kitchenType"] = unit?.kitchenType! as AnyObject?
        return dictionary
    }
    
}
