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
    
    public init(searchType:VacationSearchType) {
        self.searchType = searchType
    }

    open func hasResorts() -> Bool {
        guard let list = resorts else { return false }
        return !list.isEmpty
    }

    open func hasDestination() -> Bool {
        return self.destination != nil
    }

    open func hasArea() -> Bool {
        return self.area != nil
    }

}
