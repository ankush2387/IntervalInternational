//
//  ExchangeSearchDatesRequest.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 6/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ExchangeSearchDatesRequest {
    
    open var checkInFromDate : Date?
    open var checkInToDate : Date?
    open lazy var resorts = [Resort]()
    open lazy var areas = [Area]()
    open lazy var destinations = [AreaOfInfluenceDestination]()
    open var travelParty : TravelParty?
    open lazy var relinquishmentsIds = [String]()
    
    public init() {
    }
    
    open func setCheckInToDate(_ days:Int) {
        if self.checkInFromDate == nil {
            self.checkInFromDate = Date()
        }
        
        self.checkInToDate = self.checkInFromDate!.addingTimeInterval( Double(days) * 60 * 60 * 24)
    }
    
    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        
        dictionary["checkInFromDate"] = self.checkInFromDate!.stringWithShortFormatForJSON() as AnyObject?
        dictionary["checkInToDate"]   = self.checkInToDate!.stringWithShortFormatForJSON() as AnyObject?
        
        // Add AOI Destinations
        if self.destinations.count > 0 {
            var destinationCodes = [Dictionary<String, String>]()
            for destination in self.destinations {
                destinationCodes.append( [ "id" : destination.destinationId!, "aoiId" : destination.aoiId! ] )
            }
            
            dictionary["destinations"] = destinationCodes as AnyObject?
        }
        
        // Add resorts (if any)
        if self.resorts.count > 0 {
            var resortCodes = [String]()
            for resort in self.resorts {
                resortCodes.append( resort.resortCode! )
            }
            
            dictionary["resortCodes"] = resortCodes as AnyObject?
        }
        
        // Add Areas (if any)
        if self.areas.count > 0 {
            var areaCodes = [Int]()
            for area in self.areas {
                areaCodes.append( area.areaCode )
            }
            
            dictionary["areaCodes"] = areaCodes as AnyObject?
        }
        
        dictionary["travelParty"] = self.travelPartyToDictionary() as AnyObject?
        dictionary["relinquishments"] = self.relinquishmentsIds as AnyObject?
        
        return dictionary
    }
    
    private func travelPartyToDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["adults"] = self.travelParty?.adults as AnyObject?
        dictionary["children"] = self.travelParty?.children as AnyObject?
        return dictionary
    }
    
    
    open func toJSON() -> JSON {
        return JSON(self.toDictionary())
    }
    
    open func toJSONString() -> String {
        return self.toJSON().rawString()!
    }
    
}
