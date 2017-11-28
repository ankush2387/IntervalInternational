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
        self.searchCriteria = VacationSearchCriteria(searchType: VacationSearchType.Rental)
        self.sortType = AvailabilitySortType.Default
        self.bookingWindow = BookingWindow(checkInDate: Date())
    }
    
    public init(_ settings:Settings!, _ searchCriteria:VacationSearchCriteria!) {
        self.settings = settings
        self.searchCriteria = searchCriteria
        self.sortType = AvailabilitySortType.Default
        
        if (searchCriteria.isForBookingWindowWithFixInterval()) {
            // Apply for: Flexchange, Rental Alert
            self.bookingWindow = BookingWindow(startDate: searchCriteria.checkInFromDate, endDate: searchCriteria.checkInToDate)
        } else if (searchCriteria.isForBookingWindowWithIntervals()) {
            // Aplly for: Regular Retal|Exchange|Combined, Rental Deal
            self.bookingWindow = BookingWindow(checkInDate: searchCriteria.checkInToDate)
        } else {
            self.bookingWindow = BookingWindow(checkInDate: Date())
        }
        
        if (settings.vacationSearch?.vacationSearchTypes.contains(searchCriteria.searchType.name))! {
            if (self.searchCriteria.searchType.isCombined()) {
                self.rentalSearch = RentalSearch(self.searchCriteria, self.bookingWindow)
                self.exchangeSearch = ExchangeSearch(self.searchCriteria, self.bookingWindow)
            } else if (self.searchCriteria.searchType.isExchange()) {
                self.exchangeSearch = ExchangeSearch(self.searchCriteria, self.bookingWindow)
            } else if (self.searchCriteria.searchType.isRental()) {
                self.rentalSearch = RentalSearch(self.searchCriteria, self.bookingWindow)
            }
        }
    }
    
    open func hasRentalSearch() -> Bool {
        return self.rentalSearch != nil
    }

    open func hasExchangeSearch() -> Bool {
        return self.exchangeSearch != nil
    }
    
    open func resolveCheckInDateForInitialSearch() {
        self.searchCheckInDate = self.resolveCheckInDate(strategy: BookingIntervalDateStrategy.Nearest)!
    }
    
    open func resolveCheckInDateBasedOnAppSettings() {
        self.searchCheckInDate = self.resolveCheckInDate(strategy: BookingIntervalDateStrategy.fromName(name: (self.settings.vacationSearch?.bookingIntervalDateStrategy!)!))!
    }
    
    open func updateActiveInterval(activeInterval:BookingWindowInterval?) {
        activeInterval?.fetchedBefore = true;
        activeInterval?.checkInDates = self.getCheckInDatesFromSearchDatesOut()
        activeInterval?.resortCodes = self.getResortCodesFromSearchDatesOut()
    }
    
    /*
     * Create the Calendar that UI need to show up in the Search Availability Results screen.
     */
    open func createCalendar() -> [CalendarItem] {
        var calendar = [CalendarItem]()
        
        for interval in self.bookingWindow.intervals {
            let calendarItem = CalendarItem(intervalStartDate: (interval.startDate?.stringWithShortFormatForJSON())!,
                                            intervalEndDate: (interval.endDate?.stringWithShortFormatForJSON())!)
            
            if (interval.fetchedBefore) {
                if (interval.hasCheckInDates()) {
                    if (self.settings.vacationSearch?.collapseBookingIntervalsOnChange)! {
                        if (interval.active) {
                            // Expand only the active booking interval with his checkInDates
                            for checkInDate in interval.checkInDates! {
                                // Add the calendar item as a Single CheckIn Date
                                calendar.append(CalendarItem(checkInDate: checkInDate))
                            }
                        } else {
                            // Add the calendar item as a Range of Dates
                            calendar.append(calendarItem)
                        }
                    } else {
                        // Expand all the booking intervals with his checkInDates
                        for checkInDate in interval.checkInDates! {
                            // Add the calendar item as a Single CheckIn Date
                            calendar.append(CalendarItem(checkInDate: checkInDate))
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
        if (settings.vacationSearch?.vacationSearchTypes.contains(searchCriteria.searchType.name))! {
            if (self.searchCriteria.searchType.isCombined()) {
                return self.groupAndSorting(sortType: self.sortType)
            } else if (self.searchCriteria.searchType.isExchange()) {
                return self.exchangeSearch!.groupAndSorting(sortType: self.sortType)
            } else if (self.searchCriteria.searchType.isRental()) {
                return self.rentalSearch!.groupAndSorting(sortType: self.sortType)
            }
        }
        // return empty list
        return [AvailabilitySection]()
    }
    
    /*
     * Resolve the next interval based on intervalStartDate and intervalEndDate
     */
    open func resolveNextActiveIntervalFor(intervalStartDate:String!, intervalEndDate:String!) -> BookingWindowInterval? {
        let activeInterval = self.bookingWindow.getIntervalFor(startDate: intervalStartDate.dateFromShortFormat(), endDate: intervalEndDate.dateFromShortFormat())
        if (activeInterval != nil) {
            // Reset the previous active interval
            self.bookingWindow.resetIntervals()
            // Set the activeInterval as active
            activeInterval?.active = true
        }
        return activeInterval
    }

    private func resolveCheckInDate(strategy:BookingIntervalDateStrategy!) -> String? {
        let activeInterval = self.bookingWindow.getActiveInterval()
    
        if (!(activeInterval?.hasCheckInDates())!) {
            return nil
        }
    
        if (strategy.isFirst()) {
            return (activeInterval?.checkInDates?.first)!
        } else if (strategy.isMiddle()) {
            if ((activeInterval?.checkInDates?.count)! > 2) {
                return activeInterval?.checkInDates?[(activeInterval?.checkInDates?.count)! / 2]
            } else {
                return (activeInterval?.checkInDates?.first)!
            }
        } else if (strategy.isNearest()) {
            let from = self.searchCriteria.checkInDate
            var diffInDaysList = [Int]()
            for checkInDate in (activeInterval?.checkInDates)! {
                diffInDaysList.append((from?.daysBetween(to: checkInDate.dateFromShortFormat()))!)
            }
            let closetDiff = diffInDaysList.closetIndexTo(0)
            let index = diffInDaysList.index(of: closetDiff)
            return activeInterval?.checkInDates?[index! >= 0 ? index! : 0]
        } else {
            return nil;
        }
    }
  
    /*
     * Merge checkInDates from SeacrhDatesOut based on VacationSearchType
     */
    private func getCheckInDatesFromSearchDatesOut() -> [String] {
        var checkInDates = Set<String>()
        if (settings.vacationSearch?.vacationSearchTypes.contains(searchCriteria.searchType.name))! {
            if (self.searchCriteria.searchType.isCombined()) {
                for checkInDate in (self.rentalSearch!.searchContext.getCheckInDatesFromSeacrhDatesOut()) {
                    checkInDates.insert(checkInDate)
                }
                
                for checkInDate in (self.exchangeSearch!.searchContext.getCheckInDatesFromSeacrhDatesOut()) {
                    checkInDates.insert(checkInDate)
                }
            } else if (self.searchCriteria.searchType.isExchange()) {
                for checkInDate in (self.exchangeSearch!.searchContext.getCheckInDatesFromSeacrhDatesOut()) {
                    checkInDates.insert(checkInDate)
                }
            } else if (self.searchCriteria.searchType.isRental()) {
                for checkInDate in (self.rentalSearch!.searchContext.getCheckInDatesFromSeacrhDatesOut()) {
                    checkInDates.insert(checkInDate)
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
        if (settings.vacationSearch?.vacationSearchTypes.contains(searchCriteria.searchType.name))! {
            if (self.searchCriteria.searchType.isCombined()) {
                for resortCode in (self.rentalSearch!.searchContext.getResortCodesFromSearchDatesOut()) {
                    resortCodes.insert(resortCode)
                }
                
                for resortCode in (self.exchangeSearch!.searchContext.getResortCodesFromSearchDatesOut()) {
                    resortCodes.insert(resortCode)
                }
            } else if (self.searchCriteria.searchType.isExchange()) {
                for resortCode in (self.exchangeSearch!.searchContext.getResortCodesFromSearchDatesOut()) {
                    resortCodes.insert(resortCode)
                }
            } else if (self.searchCriteria.searchType.isRental()) {
                for resortCode in (self.rentalSearch!.searchContext.getResortCodesFromSearchDatesOut()) {
                    resortCodes.insert(resortCode)
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
        
        if (rentalInventory == nil && exchangeInventory == nil) {
            // return empty list
            return [AvailabilitySection]()
        } else {
            var sectionsMap = [String: AvailabilitySection]()
            
            // Add all the Rental sections
            for rentalSection in (self.rentalSearch?.groupAndSorting(sortType: sortType))! {
                sectionsMap[rentalSection.header!] = rentalSection
            }
            
            // Verify all the Exchange sections
            for exchangeSection in (self.exchangeSearch?.groupAndSorting(sortType: sortType))! {
                if (sectionsMap[exchangeSection.header!] == nil) {
                    sectionsMap[exchangeSection.header!] = exchangeSection
                } else {
                    // Section with same header already exists? -> then Merge
                    for exchangeSectionItem in exchangeSection.items! {
                        let resortCode = exchangeSectionItem.exchangeAvailability?.resort?.resortCode
                        
                        // Get Rental section items from map
                        var rentalSectionItems = sectionsMap[exchangeSection.header!]?.items
                        
                        // Compare ResortCode and UnitInfo
                        for rentalSectionItem in rentalSectionItems! {
                            if (rentalSectionItem.rentalAvailability?.resortCode == resortCode) {
                                // Resort Match
                                DarwinSDK.logger.info("Resort Match: \(String(describing: rentalSectionItem.rentalAvailability?.resortCode!))")
                                
                                var unitMatch = false
                                for exchangeBucket in (exchangeSectionItem.exchangeAvailability?.inventory?.buckets)! {
                                    for rentalBucket in (rentalSectionItem.rentalAvailability?.inventory?.units)! {
                                        if (rentalBucket.unitSize == exchangeBucket.unit?.unitSize &&
                                            rentalBucket.kitchenType == exchangeBucket.unit?.kitchenType &&
                                            rentalBucket.publicSleepCapacity == exchangeBucket.unit?.publicSleepCapacity &&
                                            rentalBucket.privateSleepCapacity == exchangeBucket.unit?.privateSleepCapacity) {
                                            
                                            // Unit Match
                                            DarwinSDK.logger.info("   Unit Match: \(String(describing: self.resolveUnitInfo(unit: rentalBucket)))")
                                            
                                            rentalBucket.vacationSearchType = VacationSearchType.Combined
                                            exchangeBucket.unit?.vacationSearchType = VacationSearchType.Combined
                                            unitMatch = true
                                        }
                                        
                                        if (unitMatch) {
                                            // Combined item
                                            rentalSectionItem.exchangeAvailability = exchangeSectionItem.exchangeAvailability
                                        } else {
                                            // Only Exchange item
                                            rentalSectionItems?.append(AvailabilitySectionItem(exchangeAvailability: exchangeSectionItem.exchangeAvailability!))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            var sections = [AvailabilitySection]()
            for section in sectionsMap.values {
                sections.append(section)
            }
            sections.sort(by:{$0.exactMatch! && !$1.exactMatch!})
            
            return sections
        }
    }
    
    // FIXME(Frank): Sorting rules for Combined are pending.
    private func sortSections(sections:[AvailabilitySection]) -> [AvailabilitySection] {
        return sections
    }
    
    private func resolveUnitInfo(unit:InventoryUnit) -> String {
        var info = String()
        info.append("    ")
        info.append(unit.unitSize!)
        info.append(" ")
        info.append(unit.kitchenType!)
        info.append(" ")
        info.append("\(String(describing: unit.publicSleepCapacity))")
        info.append(" total ")
        info.append("\(String(describing: unit.privateSleepCapacity))")
        info.append(" private")
        return info
    }

}
