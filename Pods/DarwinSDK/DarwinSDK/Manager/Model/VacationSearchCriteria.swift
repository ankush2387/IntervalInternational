//
//  VacationSearchCriteria.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class VacationSearchCriteria {
    
    open var searchType : VacationSearchType
    open var checkInDate : Date?
    open var checkInFromDate : Date?
    open var checkInToDate : Date?
    open var resorts : [Resort]?
    open var destination : AreaOfInfluenceDestination?
    open var area : Area?
    open var travelParty : TravelParty?
    open var relinquishmentsIds : [String]?
    
    public init(searchType:VacationSearchType!) {
        self.searchType = searchType
    }
    
    open func hasResorts() -> Bool {
        return self.resorts != nil && (self.resorts?.count)! > 0;
    }
    
    open func hasDestination() -> Bool {
        return self.destination != nil;
    }
    
    open func hasArea() -> Bool {
        return self.area != nil;
    }
    
    open func isForBookingWindowWithIntervals() -> Bool {
        return self.checkInDate != nil && self.checkInFromDate == nil && self.checkInToDate == nil
    }
    
    open func isForBookingWindowWithFixInterval() -> Bool {
        return self.checkInFromDate != nil && self.checkInToDate != nil
    }
    
}
