//
//  AvailabilitySection.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class AvailabilitySection {
    
    open var items : [AvailabilitySectionItem]?
    open var exactMatch : Bool?
    open var header : String?
    
    /**
     * Create an item with Destination
     */
    public init(items:[AvailabilitySectionItem], destination:AreaOfInfluenceDestination, exactMatch:Bool) {
        self.items = items
        self.exactMatch = exactMatch
        
        // Resolve the header
        if (exactMatch) {
            self.header = "Results in \(String(describing: self.resolveDestinationInfo(destination: destination)))"
        } else {
            self.header = "Results near \(String(describing: self.resolveDestinationInfo(destination: destination)))"
        }
    }
    
    /**
     * Create an item with Resorts
     */
    public init(items:[AvailabilitySectionItem], resortNames:[String]) {
        self.items = items
        
        // Resolve the header
        if (resortNames.count > 0) {
            if (resortNames.count == 1) {
                self.header = "\(resortNames[0])"
            } else {
                self.header = "\(resortNames[0]) + \(resortNames.count-1) more"
            }
        }
    }
    
    /**
     * Create an item with Area
     */
    public init(items:[AvailabilitySectionItem], areaName:String!) {
        self.items = items
        
        // Resolve the header
        self.header = "\(areaName)"
    }

    open func hasItems() -> Bool {
        return self.items != nil && self.items!.count > 0
    }
    
    private func resolveDestinationInfo(destination:AreaOfInfluenceDestination) -> String {
        var info = String()
        info.append(destination.destinationName)
        
        if (destination.address?.cityName != nil) {
            info.append(" ")
            info.append((destination.address?.cityName)!)
        }
        
        if (destination.address?.territoryCode != nil) {
            info.append(" ")
            info.append((destination.address?.territoryCode)!)
        }
        
        if (destination.address?.countryCode != nil) {
            info.append(" ")
            info.append((destination.address?.countryCode)!)
        }
        
        return info
    }
    
}
