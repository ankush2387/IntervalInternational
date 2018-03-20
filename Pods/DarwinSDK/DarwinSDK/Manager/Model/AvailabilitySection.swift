//
//  AvailabilitySection.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class AvailabilitySection {

    open lazy var items = [AvailabilitySectionItem]()
    open var exactMatch : Bool = false
    open var header : String = ""
    
    /**
     * Create an item with Destination
     */
    public init(items:[AvailabilitySectionItem], destination:AreaOfInfluenceDestination, exactMatch:Bool) {
        self.items.append(contentsOf: items)
        self.exactMatch = exactMatch
        
        // Resolve the header
        self.header = exactMatch ? "Results in \(self.resolveDestinationInfo(destination))"
            : "Results near \(self.resolveDestinationInfo(destination))"
    }
    
    /**
     * Create an item with Resorts
     */
    public init(items:[AvailabilitySectionItem], resortNames:[String]) {
        self.items.append(contentsOf: items)
        self.exactMatch = true
        
        // Resolve the header
        if !resortNames.isEmpty {
            self.header = resortNames.count == 1 ? resortNames[0] : "\(resortNames[0]) + \(resortNames.count-1) more"
        }
    }
    
    /**
     * Create an item with Area
     */
    public init(items:[AvailabilitySectionItem], areaName:String) {
        self.items.append(contentsOf: items)
        self.exactMatch = true
        
        // Resolve the header
        self.header = areaName
    }

    open func hasItems() -> Bool {
        return !items.isEmpty
    }

    fileprivate func resolveDestinationInfo(_ destination:AreaOfInfluenceDestination) -> String {
        var info = String()
        info.append(destination.destinationName)
        
        if let address = destination.address {
            if let cityName = address.cityName {
                info.append(" ")
                info.append(cityName)
            }
            
            if let territoryCode = address.territoryCode {
                info.append(" ")
                info.append(territoryCode)
            }
            
            if let countryCode = address.countryCode {
                info.append(" ")
                info.append(countryCode)
            }
        }

        return info
    }
    
}
