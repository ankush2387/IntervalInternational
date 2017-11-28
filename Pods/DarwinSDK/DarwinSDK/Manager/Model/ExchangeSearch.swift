//
//  ExchangeSearch.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class ExchangeSearch {
    
    open var searchContext : ExchangeSearchContext
    open var resortNames : [String]?
    open var areaName : String?
    open var inventory : [ExchangeAvailability]?

    public init(_ searchCriteria:VacationSearchCriteria!, _ bookingWindow:BookingWindow!) {
        let activeInterval = bookingWindow.getActiveInterval()
        let request = ExchangeSearchDatesRequest()
        request.checkInFromDate = activeInterval?.startDate
        request.checkInToDate = activeInterval?.endDate
        request.travelParty = searchCriteria.travelParty
        request.relinquishmentsIds = searchCriteria.relinquishmentsIds!
        
        if (searchCriteria.hasDestination()) {
            request.destinations.append(searchCriteria.destination!)
        } else if (searchCriteria.hasResorts()) {
            request.resorts.append(contentsOf: searchCriteria.resorts!)
            
            resortNames = [String]()
            for resort in searchCriteria.resorts! {
                resortNames?.append(resort.resortName!)
            }
        } else if (searchCriteria.hasArea()) {
            request.areas.append(searchCriteria.area!)
            
            areaName = searchCriteria.area?.areaName
        }
        
        self.searchContext = ExchangeSearchContext(request: request)
    }
    
    open func hasInventory() -> Bool {
        return self.inventory != nil && (self.inventory?.count)! > 0
    }
    
    open func groupAndSorting(sortType:AvailabilitySortType) -> [AvailabilitySection] {
        return (sortType.isDefault()) ? self.sortSectionsByDefault(sections: self.groupSections())
            : self.sortSections(sortType: sortType, sections: self.groupSections())
    }
    
    private func groupSections() -> [AvailabilitySection] {
        var sections = [AvailabilitySection]()
        
        if (self.hasInventory()) {
            
            if (self.searchContext.hasInDestinations()) {
                var surroundingMatchSections = [AvailabilitySection]()
                
                // Create sections (Exact & Surrounding) for each Destination
                for destination in (self.searchContext.request.destinations) {
                    var exactMatchExchangeInventory = [String: ExchangeAvailability]()
                    var surroundingMatchExchangeInventory = [String: ExchangeAvailability]()
                    
                    // Grouping buckets into sections: Exact, Surrounding
                    for inventoryItem in self.inventory! {
                        if (self.searchContext.hasOutResortCodes()
                            && (self.searchContext.response.resortCodes.contains((inventoryItem.resort?.resortCode!)!))) {
                            
                            for exchangeBucket in (inventoryItem.inventory?.buckets)! {
                                exchangeBucket.unit?.vacationSearchType = VacationSearchType.Exchange
                            }
                            exactMatchExchangeInventory[(inventoryItem.resort?.resortCode!)!] = inventoryItem
                        }
                        
                        if (self.searchContext.hasOutSurroundingResortCodes()
                            && (self.searchContext.response.surroundingResortCodes.contains((inventoryItem.resort?.resortCode!)!))) {
                            
                            for exchangeBucket in (inventoryItem.inventory?.buckets)! {
                                exchangeBucket.unit?.vacationSearchType = VacationSearchType.Exchange
                            }
                            surroundingMatchExchangeInventory[(inventoryItem.resort?.resortCode!)!] = inventoryItem
                        }
                    }
                    
                    if (exactMatchExchangeInventory.count > 0) {
                        // Items should be show up into the Exact Match section for each Destination.
                        var items = [AvailabilitySectionItem]()
                        for exchangeAvailability in exactMatchExchangeInventory.values {
                            let item = AvailabilitySectionItem(exchangeAvailability: exchangeAvailability)
                            items.append(item)
                        }
                        sections.append(AvailabilitySection(items: items, destination: destination, exactMatch: true))
                    }
                    
                    if (surroundingMatchExchangeInventory.count > 0) {
                        // Items should be show up into the Surrounding Match section for each Destination.
                        var items = [AvailabilitySectionItem]()
                        for exchangeAvailability in surroundingMatchExchangeInventory.values {
                            let item = AvailabilitySectionItem(exchangeAvailability: exchangeAvailability)
                            items.append(item)
                        }
                        surroundingMatchSections.append(AvailabilitySection(items: items, destination: destination, exactMatch: false))
                    }
                    
                }
                
                // Merge sections: Exact, Surrounding
                for surroundingMatchSection in surroundingMatchSections {
                    sections.append(surroundingMatchSection)
                }
                
            } else if (searchContext.hasInResortCodes()) {
                sections.append(AvailabilitySection(items: createSectionItems(), resortNames: resortNames!))
            } else if (self.searchContext.hasInAreas()) {
                sections.append(AvailabilitySection(items: createSectionItems(), areaName: areaName))
            }
        }
  
        return sections
    }
    
    private func createSectionItems() -> [AvailabilitySectionItem] {
        var exchangeInventory = [String: ExchangeAvailability]()
        for inventoryItem in self.inventory! {
            if (self.searchContext.hasOutResortCodes()
                && (self.searchContext.response.resortCodes.contains((inventoryItem.resort?.resortCode!)!))) {
                
                for exchangeBucket in (inventoryItem.inventory?.buckets)! {
                    exchangeBucket.unit?.vacationSearchType = VacationSearchType.Exchange
                }
                exchangeInventory[(inventoryItem.resort?.resortCode!)!] = inventoryItem
            }
        }
        
        var items = [AvailabilitySectionItem]()
        for exchangeAvailability in exchangeInventory.values {
            let item = AvailabilitySectionItem(exchangeAvailability: exchangeAvailability)
            items.append(item)
        }
        
        return items
    }

    private func sortSectionsByDefault(sections:[AvailabilitySection]) -> [AvailabilitySection] {
        // Sort Resorts
        for section in sections {
            // Rule 1: Resort Name (alphabetical: A -> Z)
            section.items?.sort(by: {$0.exchangeAvailability?.resort?.resortName?.localizedCaseInsensitiveCompare(
                ($1.exchangeAvailability?.resort?.resortName!)!) == ComparisonResult.orderedAscending})
            
            // Rule 2: TrackCode Category (highest TrackCode weight value within available resort units)
            section.items?.sort(by: {self.resolveHighestTrackCode($0.exchangeAvailability!) > self.resolveHighestTrackCode($1.exchangeAvailability!)})

            // Sort Buckets
            self.sortBuckets(section)
        }
        
        return sections
    }

    private func sortSections(sortType:AvailabilitySortType, sections:[AvailabilitySection]) -> [AvailabilitySection] {
        // Sort Resorts
        if (sortType.isResortNameAsc()) {
            for section in sections {
                // Resort Name (alphabetical: A -> Z)
                section.items?.sort(by: {$0.exchangeAvailability?.resort?.resortName?.localizedCaseInsensitiveCompare(
                    ($1.exchangeAvailability?.resort?.resortName!)!) == ComparisonResult.orderedAscending})
                // Sort Buckets
                self.sortBuckets(section)
            }
        } else if (sortType.isResortNameDesc()) {
            for section in sections {
                // Resort Name (alphabetical: Z -> A)
                section.items?.sort(by: {$1.exchangeAvailability?.resort?.resortName?.localizedCaseInsensitiveCompare(
                    ($0.exchangeAvailability?.resort?.resortName!)!) == ComparisonResult.orderedAscending})
                // Sort Buckets
                self.sortBuckets(section)
            }
        } else if (sortType.isCityNameAsc()) {
            for section in sections {
                // City Name (alphabetical: A -> Z)
                section.items?.sort(by: {$0.exchangeAvailability?.resort?.address?.cityName?.localizedCaseInsensitiveCompare(
                    ($1.exchangeAvailability?.resort?.address?.cityName!)!) == ComparisonResult.orderedAscending})
                // Sort Buckets
                self.sortBuckets(section)
            }
        } else if (sortType.isCityNameDesc()) {
            for section in sections {
                // City Name (alphabetical: Z -> A)
                section.items?.sort(by: {$1.exchangeAvailability?.resort?.address?.cityName?.localizedCaseInsensitiveCompare(
                    ($0.exchangeAvailability?.resort?.address?.cityName!)!) == ComparisonResult.orderedAscending})
                // Sort Buckets
                self.sortBuckets(section)
            }
        } else if (sortType.isResortTierHighToLow()) {
            for section in sections {
                // Resort Tier (highest Tier weigt value)
                section.items?.sort(by: {self.resolveHighestTier(($0.exchangeAvailability?.resort!)!) > self.resolveHighestTier(($1.exchangeAvailability?.resort!)!)})
                // Sort Buckets
                self.sortBuckets(section)
            }
        } else if (sortType.isResortTierLowToHigh()) {
            for section in sections {
                // Resort Tier (lowest Tier weigt value)
                section.items?.sort(by: {self.resolveHighestTier(($0.exchangeAvailability?.resort!)!) < self.resolveHighestTier(($1.exchangeAvailability?.resort!)!)})
                // Sort Buckets
                self.sortBuckets(section)
            }
        }
        
        return sections
    }
    
    private func sortBuckets(_ section:AvailabilitySection) {
        // Sort Buckets
        for item in section.items! {
            // Rule A: TrackCode Category (highest TrackCode weight value)
            item.exchangeAvailability?.inventory?.buckets.sort(by: {TrackCodeCategory.fromName(name: $0.trackCodeCategory!).weigth >
                TrackCodeCategory.fromName(name: $1.trackCodeCategory!).weigth})
        }
    }

    private func resolveHighestTrackCode(_ availability:ExchangeAvailability) -> Int {
        var highestTrackCodeWeight = 0
        for bucket in (availability.inventory?.buckets)! {
            let weigth = TrackCodeCategory.fromName(name: bucket.trackCodeCategory!).weigth
            if (weigth > highestTrackCodeWeight) {
                highestTrackCodeWeight = weigth
            }
        }
        return highestTrackCodeWeight
    }

    private func resolveHighestTier(_ resort:Resort) -> Int {
        var highestTierWeight = 0
        let weigth = Tier.fromName(name: resort.tier!).weigth
        if (weigth > highestTierWeight) {
            highestTierWeight = weigth
        }
        return highestTierWeight
    }

}

