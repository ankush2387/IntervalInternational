//
//  RentalAlert.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 8/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalAlert {
    
    open var alertId : Int64? = 0
    open var name : String?
    open var earliestCheckInDate : String?
    open var latestCheckInDate : String?
    open var enabled : Bool? = false
    open lazy var destinations = [AreaOfInfluenceDestination]()
    open lazy var resorts = [Resort]()
    open lazy var selections = [MapSelection]()
    open lazy var unitSizes = [UnitSize]()
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.alertId = json["id"].int64Value
        self.name = json["name"].string ?? "(Untitled)"
        self.enabled = json["enabled"].boolValue
        self.earliestCheckInDate = json["earliestCheckInDate"].string ?? ""
        self.latestCheckInDate = json["latestCheckInDate"].string ?? ""
   
        if json["destinations"].exists() {
            let destinationsJsonArray:[JSON] = json["destinations"].arrayValue
            self.destinations = destinationsJsonArray.map { AreaOfInfluenceDestination(json:$0) }
        }

		if json["resorts"].exists() {
			let resortsJsonArray:[JSON] = json["resorts"].arrayValue
            self.resorts = resortsJsonArray.map { Resort(summaryJSON:$0) }
        }
 
		if json["selections"].exists() {
			let selectionsJsonArray:[JSON] = json["selections"].arrayValue
            self.selections = selectionsJsonArray.map { MapSelection(json:$0) }
        }
        
        if json["unitSizes"].exists() {
            let unitSizesJsonArray:[JSON] = json["unitSizes"].arrayValue
            self.unitSizes = unitSizesJsonArray.map { UnitSize(rawValue: $0.stringValue) ?? UnitSize.Unknown }
        }
    }
    
    open func getCheckInDate() -> String {
        // FIXME(Frank): Derive a date in the middle of: alert.earliestCheckInDate and alert.latestCheckInDate
        return self.earliestCheckInDate!
    }
    
    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        
        dictionary["name"] = self.name as AnyObject?
        dictionary["earliestCheckInDate"] = self.earliestCheckInDate as AnyObject?
        dictionary["latestCheckInDate"]   = self.latestCheckInDate as AnyObject?
        dictionary["enabled"] = self.enabled as AnyObject?
        dictionary["destinations"] = self.destinationsToArray() as AnyObject?
        dictionary["resorts"] = self.resortsToArray() as AnyObject?
        dictionary["selections"] = self.selections as AnyObject?
        dictionary["unitSizes"] = self.unitSizes.map { $0.rawValue } as AnyObject?
   
        return dictionary
    }
    
    private func destinationsToArray() -> Array<AnyObject> {
        var destinationArray = Array<AnyObject>()
        if self.destinations.count > 0 {
            for destination in self.destinations {
                destinationArray.append(self.destinationToDictionary(destination: destination) as AnyObject)
            }
        }
        return destinationArray
    }
    
    private func destinationToDictionary(destination: AreaOfInfluenceDestination) -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["id"] = destination.destinationId as AnyObject?
        dictionary["aoiId"] = destination.aoiId as AnyObject?
        dictionary["sortOrderNum"] = destination.sortOrderNum as AnyObject?
        return dictionary
    }
    
    private func resortsToArray() -> Array<AnyObject> {
        var resortArray = Array<AnyObject>()
        if self.resorts.count > 0 {
            for resort in self.resorts {
                resortArray.append(self.resortToDictionary(resort: resort) as AnyObject)
            }
        }
        return resortArray
    }
    
    private func resortToDictionary(resort: Resort) -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["code"] = resort.resortCode as AnyObject?
        return dictionary
    }

}
