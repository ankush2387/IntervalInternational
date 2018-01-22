//
//  RentalSearchContext.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class RentalSearchContext {
    
    open var request : RentalSearchDatesRequest
    open var response :  RentalSearchDatesResponse

    public init(request:RentalSearchDatesRequest) {
        self.request = request
        self.response = RentalSearchDatesResponse()
    }
    
    /*
     * Check if the request of Rental Search Dates has resortCodes
     */
    open func hasInResortCodes() -> Bool {
       return !self.request.resorts.isEmpty
    }
    
    /*
     * Check if the request of Rental Search Dates has destinations
     */
    open func hasInDestinations() -> Bool {
        return !self.request.destinations.isEmpty
    }
    
    /*
     * Check if the request of Rental Search Dates has areas
     */
    open func hasInAreas() -> Bool {
        return !self.request.areas.isEmpty
    }

    /*
     * Check if the response of Rental Search Dates has checkInDates
     */
    open func hasOutCheckInDates() -> Bool {
        return !self.response.checkInDates.isEmpty
    }
    
    /*
     * Check if the response of Rental Search Dates has surroundingCheckInDates
     */
    open func hasOutSurroundingCheckInDates() -> Bool {
        return hasInDestinations() && !self.response.surroundingCheckInDates.isEmpty
    }
    
    /*
     * Check if the response of Rental Search Dates has resortCodes
     */
    open func hasOutResortCodes() -> Bool {
        return !self.response.resortCodes.isEmpty
    }
    
    /*
     * Check if the response of Rental Search Dates has surroundingResortCodes
     */
    open func hasOutSurroundingResortCodes() -> Bool {
        return hasInDestinations() && !self.response.surroundingResortCodes.isEmpty
    }
    
    
    /*
     * Get Rental resortCodes from SearchDatesResponse
     */
    open func getResortCodesFromSearchDatesOut() -> [String] {
        var resortCodes = Set<String>()
        
        if self.hasOutResortCodes() {
            for resortCode in self.response.resortCodes {
                resortCodes.insert(resortCode)
            }
        }
        
        if self.hasOutSurroundingResortCodes() {
            for resortCode in self.response.surroundingResortCodes {
                resortCodes.insert(resortCode)
            }
        }

        return Array(resortCodes)
    }
    
    /*
     * Get Rental checkInDates from SearchDatesResponse
     */
    open func getCheckInDatesFromSeacrhDatesOut() -> [String] {
        var checkInDates = Set<String>()
        
        if self.hasOutCheckInDates() {
            for checkInDate in self.response.checkInDates {
                checkInDates.insert(checkInDate.stringWithShortFormatForJSON())
            }
        }
        
        if self.hasOutSurroundingCheckInDates() {
            for checkInDate in self.response.surroundingCheckInDates {
                checkInDates.insert(checkInDate.stringWithShortFormatForJSON())
            }
        }
        
        return Array(checkInDates)
    }
    
    /*
     * Check if the Availability Inventory bucket is an exact match
     */
    open func isExactMatch(checkInDate:Date) -> Bool {
        return hasOutCheckInDates() && self.response.checkInDates.contains(checkInDate)
    }
    
    /*
     * Check if the Availability Inventory bucket is a surrounding match
     */
    open func isSurroundingMatch(checkInDate:Date) -> Bool {
        return hasOutSurroundingCheckInDates() && self.response.surroundingCheckInDates.contains(checkInDate)
    }

}
