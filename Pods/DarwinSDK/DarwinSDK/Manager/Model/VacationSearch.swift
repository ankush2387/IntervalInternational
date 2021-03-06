//
//  VacationSearch.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class VacationSearch {
    
    open var settings : Settings
    open var searchCriteria : VacationSearchCriteria
    open var bookingWindow : BookingWindow
    open var sortType : AvailabilitySortType
    open var rentalSearch : RentalSearch?
    open var exchangeSearch : ExchangeSearch?
    open var searchCheckInDate : String?
    
    public init() {
        self.settings = Settings()
        self.searchCriteria = VacationSearchCriteria(searchType: VacationSearchType.RENTAL)
        self.sortType = AvailabilitySortType.Default
        self.bookingWindow = BookingWindow(checkInDate: Date())
    }
    
    public init(_ settings:Settings, _ searchCriteria:VacationSearchCriteria) {
        self.settings = settings
        self.searchCriteria = searchCriteria
        self.sortType = AvailabilitySortType.Default
        
        if let checkInFromDate = searchCriteria.checkInFromDate, let checkInToDate = searchCriteria.checkInToDate {
            // Apply for: Flexchange, Rental Alert
            self.bookingWindow = BookingWindow(startDate: checkInFromDate, endDate: checkInToDate)
        } else if let checkInDate = searchCriteria.checkInDate {
            // Aplly for: Regular Retal|Exchange|Combined, Rental Deal
            self.bookingWindow = BookingWindow(checkInDate: checkInDate)
        } else {
            // Fallback
            self.bookingWindow = BookingWindow(checkInDate: Date())
        }
        
        if let vacationSearchSettings = settings.vacationSearch {
            if vacationSearchSettings.vacationSearchTypes.contains(searchCriteria.searchType.name) {
                if self.searchCriteria.searchType.isCombined() {
                    self.rentalSearch = RentalSearch(self.searchCriteria, self.bookingWindow)
                    self.exchangeSearch = ExchangeSearch(self.searchCriteria, self.bookingWindow)
                } else if self.searchCriteria.searchType.isExchange() {
                    self.exchangeSearch = ExchangeSearch(self.searchCriteria, self.bookingWindow)
                } else if self.searchCriteria.searchType.isRental() {
                    self.rentalSearch = RentalSearch(self.searchCriteria, self.bookingWindow)
                }
            }
        }
    }
    
    open func hasRentalSearch() -> Bool {
        return self.rentalSearch != nil
    }
    
    open func hasExchangeSearch() -> Bool {
        return self.exchangeSearch != nil
    }
    
    open func updateActiveInterval() {
        updateActiveInterval(activeInterval: self.bookingWindow.getActiveInterval())
    }
    
    open func updateActiveInterval(activeInterval:BookingWindowInterval?) {
        if let interval = activeInterval {
            interval.fetchedBefore = true
            interval.checkInDates = self.getCheckInDatesFromSearchDatesOut()
            interval.resortCodes = self.getResortCodesFromSearchDatesOut()
        }
    }
    
    open func resolveCheckInDateForInitialSearch() {
        self.searchCheckInDate = self.resolveCheckInDate(strategy: BookingIntervalDateStrategy.NEAREST)
    }
    
    open func resolveCheckInDateBasedOnSettings() {
        if let vacationSearch = self.settings.vacationSearch, let strategyName = vacationSearch.bookingIntervalDateStrategy {
            self.searchCheckInDate = self.resolveCheckInDate(strategy: BookingIntervalDateStrategy.fromName(name: strategyName))
        }
    }
    
    /*
     * Create the Calendar that UI need to show up in the Search Availability Results screen.
     */
    open func createCalendar() -> [CalendarItem] {
        var calendar = [CalendarItem]()
        
        for interval in self.bookingWindow.intervals {
            let calendarItem = CalendarItem(intervalStartDate: interval.startDate.stringWithShortFormatForJSON(),
                                            intervalEndDate: interval.endDate.stringWithShortFormatForJSON())
            
            var collapseBookingIntervalsOnChange = false
            if let vacationSearch = self.settings.vacationSearch {
                collapseBookingIntervalsOnChange = vacationSearch.collapseBookingIntervalsOnChange
            }
            
            if interval.fetchedBefore {
                if interval.hasCheckInDates() {
                    if collapseBookingIntervalsOnChange {
                        if (interval.active) {
                            // Expand only the active booking interval with his checkInDates
                            if let checkInDates = interval.checkInDates {
                                for checkInDate in checkInDates {
                                    // Add the calendar item as a Single CheckIn Date
                                    calendar.append(CalendarItem(checkInDate: checkInDate))
                                }
                            }
                        } else {
                            // Add the calendar item as a Range of Dates
                            calendar.append(calendarItem)
                        }
                    } else {
                        // Expand all the booking intervals with his checkInDates
                        if let checkInDates = interval.checkInDates {
                            for checkInDate in checkInDates {
                                // Add the calendar item as a Single CheckIn Date
                                calendar.append(CalendarItem(checkInDate: checkInDate))
                            }
                        }
                    }
                } else {
                    // Mark the calendar item as not available.
                    calendarItem.markIntervalAsNotAvailable()
                    // Add the calendar item as a Range of Dates
                    calendar.append(calendarItem)
                }
            } else {
                // Add the calendar item as a Range of Dates
                calendar.append(calendarItem)
            }
        }
        return calendar;
    }
    
    /*
     * Create sections that UI need to show up in the Search Availability Results screen.
     */
    open func createSections() -> [AvailabilitySection] {
        if let vacationSearchSettings = self.settings.vacationSearch {
            if vacationSearchSettings.vacationSearchTypes.contains(searchCriteria.searchType.name) {
                if self.searchCriteria.searchType.isCombined() {
                    return self.groupAndSorting(sortType: self.sortType)
                } else if self.searchCriteria.searchType.isExchange() {
                    return self.exchangeSearch!.groupAndSorting(sortType: self.sortType)
                } else if self.searchCriteria.searchType.isRental() {
                    return self.rentalSearch!.groupAndSorting(sortType: self.sortType)
                }
            }
        }
        // return empty list
        return [AvailabilitySection]()
    }
    
    private func resolveCheckInDate(strategy:BookingIntervalDateStrategy) -> String? {
        if let activeInterval = self.bookingWindow.getActiveInterval(), let checkInDates = activeInterval.checkInDates {
            switch(strategy) {
            case .FIRST:
                return checkInDates.first
            case .MIDDLE:
                if checkInDates.count > 2 {
                    return checkInDates[checkInDates.count / 2]
                } else {
                    return checkInDates.first
                }
            case .NEAREST:
                if let fromCheckInDate = self.searchCriteria.checkInDate {
                    var diffInDaysList = [Int]()
                    for checkInDate in checkInDates {
                        diffInDaysList.append(fromCheckInDate.daysBetween(to: checkInDate.dateFromShortFormat()))
                    }
                    let closetDiff = diffInDaysList.closetDiffTo(0)
                    if let index = diffInDaysList.index(of: closetDiff) {
                        let nearestCheckInDate = checkInDates[index]
                        return nearestCheckInDate
                    } else {
                        // Fallback
                        return fromCheckInDate.stringWithShortFormatForJSON()
                    }
                }
            }
        }
        return nil
    }
    
    /*
     * Merge checkInDates from SeacrhDatesOut based on VacationSearchType
     */
    private func getCheckInDatesFromSearchDatesOut() -> [String] {
        var checkInDates = Set<String>()
        
        if let vacationSearch = self.settings.vacationSearch {
            if vacationSearch.vacationSearchTypes.contains(searchCriteria.searchType.name) {
                if self.searchCriteria.searchType.isCombined() {
                    if let rentalSearch = self.rentalSearch {
                        for checkInDate in rentalSearch.searchContext.getCheckInDatesFromSeacrhDatesOut() {
                            checkInDates.insert(checkInDate)
                        }
                    }
                    
                    if let exchangeSearch = self.exchangeSearch {
                        for checkInDate in exchangeSearch.searchContext.getCheckInDatesFromSeacrhDatesOut() {
                            checkInDates.insert(checkInDate)
                        }
                    }
                } else if self.searchCriteria.searchType.isExchange() {
                    if let exchangeSearch = self.exchangeSearch {
                        for checkInDate in exchangeSearch.searchContext.getCheckInDatesFromSeacrhDatesOut() {
                            checkInDates.insert(checkInDate)
                        }
                    }
                } else if self.searchCriteria.searchType.isRental() {
                    if let rentalSearch = self.rentalSearch {
                        for checkInDate in rentalSearch.searchContext.getCheckInDatesFromSeacrhDatesOut() {
                            checkInDates.insert(checkInDate)
                        }
                    }
                }
            }
        }
        
        return checkInDates.sorted()
    }
    
    /*
     * Merge resortCodes from SeacrhDatesOut based on VacationSearchType
     */
    private func getResortCodesFromSearchDatesOut() -> [String] {
        var resortCodes = Set<String>()
        
        if let vacationSearch = self.settings.vacationSearch {
            if vacationSearch.vacationSearchTypes.contains(searchCriteria.searchType.name) {
                if (self.searchCriteria.searchType.isCombined()) {
                    if let rentalSearch = self.rentalSearch {
                        for resortCode in rentalSearch.searchContext.getResortCodesFromSearchDatesOut() {
                            resortCodes.insert(resortCode)
                        }
                    }
                    
                    if let exchangeSearch = self.exchangeSearch {
                        for resortCode in exchangeSearch.searchContext.getResortCodesFromSearchDatesOut() {
                            resortCodes.insert(resortCode)
                        }
                    }
                } else if self.searchCriteria.searchType.isExchange() {
                    if let exchangeSearch = self.exchangeSearch {
                        for resortCode in exchangeSearch.searchContext.getResortCodesFromSearchDatesOut() {
                            resortCodes.insert(resortCode)
                        }
                    }
                } else if self.searchCriteria.searchType.isRental() {
                    if let rentalSearch = self.rentalSearch {
                        for resortCode in rentalSearch.searchContext.getResortCodesFromSearchDatesOut() {
                            resortCodes.insert(resortCode)
                        }
                    }
                }
            }
        }
        
        return resortCodes.sorted()
    }
    
    private func groupAndSorting(sortType:AvailabilitySortType) -> [AvailabilitySection] {
        return self.sortSections(sections: self.groupSections(sortType: sortType))
    }
    
    private func groupSections(sortType:AvailabilitySortType) -> [AvailabilitySection] {
        let rentalInventory = self.hasRentalSearch() ? self.rentalSearch?.inventory : nil;
        let exchangeInventory = self.hasExchangeSearch() ? self.exchangeSearch?.inventory : nil
        
        if rentalInventory == nil && exchangeInventory == nil {
            // return empty list
            return [AvailabilitySection]()
        } else {
            var sectionsMap = [String: AvailabilitySection]()
            
            if let rentalSearch = self.rentalSearch {
                // Add all the Rental sections
                for rentalSection in rentalSearch.groupAndSorting(sortType: sortType) {
                    sectionsMap[rentalSection.header] = rentalSection
                }
            }
            
            if let exchangeSearch = self.exchangeSearch {
                // Verify all the Exchange sections
                for exchangeSection in exchangeSearch.groupAndSorting(sortType: sortType) {
                    if sectionsMap[exchangeSection.header] == nil {
                        sectionsMap[exchangeSection.header] = exchangeSection
                    } else {
                        // Section with same header already exists? -> then merge the section items (Resort->Buckets)
                        sectionsMap[exchangeSection.header]?.items = mergeSectionItems(sectionsMap[exchangeSection.header]?.items, exchangeSection.items)
                    }
                }
            }
            
            var sections = [AvailabilitySection]()
            sections.append(contentsOf: sectionsMap.values)
            sections.sort(by:{$0.exactMatch && !$1.exactMatch})
            return sections
        }
    }
    
    private func mergeSectionItems(_ rentalSectionItems: [AvailabilitySectionItem]?, _ exchangeSectionItems: [AvailabilitySectionItem]?) -> [AvailabilitySectionItem] {
        var groupByResortCode = [String: AvailabilitySectionItem]()
        
        if let items = rentalSectionItems {
            for rentalSectionItem in items {
                if let rentalAvailability = rentalSectionItem.rentalAvailability, let rentalResortCode = rentalAvailability.resortCode {
                    groupByResortCode[rentalResortCode] = rentalSectionItem
                }
            }
        }
        
        if let items = exchangeSectionItems {
            for exchangeSectionItem in items {
                if let exchangeAvailability = exchangeSectionItem.exchangeAvailability, let exchangeResort = exchangeAvailability.resort, let exchangeResortCode = exchangeResort.resortCode {
                    if let group = groupByResortCode[exchangeResortCode] {
                        // Mean the same ResortCode has availability for Rental and Exchange
                        group.exchangeAvailability = exchangeSectionItem.exchangeAvailability
                    } else {
                        groupByResortCode[exchangeResortCode] = exchangeSectionItem
                    }
                }
            }
        }
        
        var sectionItems = [AvailabilitySectionItem]()
        sectionItems.append(contentsOf: groupByResortCode.values)
        return sectionItems
    }
    
    private func sortSections(sections:[AvailabilitySection]) -> [AvailabilitySection] {
        for section in sections {
            section.items.sort(by: {self.resolveHighestSearchType($0.getInventoryBuckets() ?? []) > self.resolveHighestSearchType($1.getInventoryBuckets() ?? [])})
        }
        return sections
    }
    
    private func resolveHighestSearchType(_ inventoryBuckets: [AvailabilitySectionItemInventoryBucket]) -> Int {
        var highestSearchTypeWeight = 0
        for inventoryBucket in inventoryBuckets {
            if inventoryBucket.vacationSearchType.weigth > highestSearchTypeWeight {
                highestSearchTypeWeight = inventoryBucket.vacationSearchType.weigth
            }
        }
        return highestSearchTypeWeight
    }
    
    private func resolveUnitInfo(unit:InventoryUnit) -> String {
        var info = String()
        info.append("    ")
        
        if let unitSize = unit.unitSize {
            info.append(unitSize)
            info.append(" ")
        }
        
        if let kitchenType = unit.kitchenType {
            info.append(kitchenType)
            info.append(" ")
        }
        
        info.append("Sleeps \(unit.tradeOutCapacity)")
        
        return info
    }
    
}
