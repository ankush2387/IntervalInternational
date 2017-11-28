//
//  PointsMatrixReservation.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 4/18/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class PointsMatrixReservation {
    
    open var clubPointsMatrixType : String?
    open var clubPointsMatrixDescription : String?
    open var clubPointsMatrixGridRowLabel : String?
    open var fromDate : String?
    open var toDate : String?
    open var unit : InventoryUnit?
 
    public init() {
    }
    
    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["type"] = self.clubPointsMatrixType as AnyObject?
        dictionary["description"] = self.clubPointsMatrixDescription as AnyObject?
        dictionary["label"] = self.clubPointsMatrixGridRowLabel as AnyObject?
        dictionary["fromDate"] = self.fromDate as AnyObject?
        dictionary["toDate"] = self.toDate as AnyObject?
        dictionary["unit"] = self.unitToDictionary() as AnyObject?
        return dictionary
    }
    
    private func unitToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["clubPoints"] = self.unit?.clubPoints as AnyObject?
        dictionary["unitSize"] = self.unit?.unitSize as AnyObject?
        return dictionary
    }
    
}

