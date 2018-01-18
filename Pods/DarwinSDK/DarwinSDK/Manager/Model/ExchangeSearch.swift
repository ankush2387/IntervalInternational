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

    public init(_ searchCriteria:VacationSearchCriteria, _ bookingWindow:BookingWindow) {
        if let activeInterval = bookingWindow.getActiveInterval() {
            let request = ExchangeSearchDatesRequest()
            request.checkInFromDate = activeInterval.startDate
            request.checkInToDate = activeInterval.endDate
            if let travelParty = searchCriteria.travelParty {
                request.travelParty = travelParty
            }
            if let relinquishmentsIds = searchCriteria.relinquishmentsIds {
                request.relinquishmentsIds.append(contentsOf: relinquishmentsIds)
            }
            
           
            
            if let destination = searchCriteria.destination {
                request.destinations.append(destination)
            } else if let resorts = searchCriteria.resorts {
                request.resorts.append(contentsOf: resorts)
                
                var resortNames = [String]()
                for resort in resorts {
                    if let resortName = resort.resortName {
                        resortNames.append(resortName)
                    }
                }
                self.resortNames = resortNames
            } else if let area = searchCriteria.area {
                request.areas.append(area)
                
                areaName = area.areaName
            }
            
            self.searchContext = ExchangeSearchContext(request: request)
        } else {
            // TODO(Frank): Should never happen
            self.searchContext = ExchangeSearchContext(request: ExchangeSearchDatesRequest())
        }
    }

    /*
    open func hasInventory() -> Bool {
        return self.inventory != nil && (self.inventory?.count)! > 0
    }
   */
    
    open func groupAndSorting(sortType:AvailabilitySortType) -> [AvailabilitySection] {
        return sortType.isDefault() ? self.sortSectionsByDefault(sections: self.groupSections())
            : self.sortSections(sortType: sortType, sections: self.groupSections())
    }
    
    private func groupSections() -> [AvailabilitySection] {
        var sections = [AvailabilitySection]()
        
        if let inventory = self.inventory {
            if (self.searchContext.hasInDestinations()) {
                var surroundingMatchSections = [AvailabilitySection]()
                
                // Create sections (Exact & Surrounding) for each Destination
                for destination in self.searchContext.request.destinations {
                    var exactMatchExchangeInventory = [String: ExchangeAvailability]()
                    var surroundingMatchExchangeInventory = [String: ExchangeAvailability]()
                    
                    // Grouping buckets into sections: Exact, Surrounding
                    for inventoryItem in inventory {
                        if let resort = inventoryItem.resort, let resortCode = resort.resortCode, let exchangeInventory = inventoryItem.inventory {
                            for exchangeBucket in exchangeInventory.buckets {
                                if let unit = exchangeBucket.unit {
                                    unit.vacationSearchType = VacationSearchType.EXCHANGE
                                }
                            }

                            if self.searchContext.hasOutResortCodes() && self.searchContext.response.resortCodes.contains(resortCode) {
                                exactMatchExchangeInventory[resortCode] = inventoryItem
                            }
                            
                            if self.searchContext.hasOutSurroundingResortCodes() && self.searchContext.response.surroundingResortCodes.contains(resortCode) {
                                surroundingMatchExchangeInventory[resortCode] = inventoryItem
                            }
                        }
                    }
                    
                    if !exactMatchExchangeInventory.isEmpty {
                        // Buckets should be show up into the Exact Match section for each Destination.
                        var items = [AvailabilitySectionItem]()
                        for exchangeAvailability in exactMatchExchangeInventory.values {
                            items.append(AvailabilitySectionItem(exchangeAvailability: exchangeAvailability))
                        }
                        sections.append(AvailabilitySection(items: items, destination: destination, exactMatch: true))
                    }
                    
                    if !surroundingMatchExchangeInventory.isEmpty {
                        // Buckets should be show up into the Surrounding Match section for each Destination.
                        var items = [AvailabilitySectionItem]()
                        for exchangeAvailability in surroundingMatchExchangeInventory.values {
                            items.append(AvailabilitySectionItem(exchangeAvailability: exchangeAvailability))
                        }
                        surroundingMatchSections.append(AvailabilitySection(items: items, destination: destination, exactMatch: false))
                    }
                }
                
                // Merge sections: Exact, Surrounding
                for surroundingMatchSection in surroundingMatchSections {
                    sections.append(surroundingMatchSection)
                }
            } else if searchContext.hasInResortCodes() {
                if let resortNames = self.resortNames {
                    sections.append(AvailabilitySection(items: createSectionItems(), resortNames: resortNames))
                }
            } else if searchContext.hasInAreas() {
                if let areaName = self.areaName {
                    sections.append(AvailabilitySection(items: createSectionItems(), areaName: areaName))
                }
            }
        }
        
        return sections
    }

    private func createSectionItems() -> [AvailabilitySectionItem] {
        var availability = [String: ExchangeAvailability]()
        
        if let inventory = self.inventory {
            for inventoryItem in inventory {
                if let resort = inventoryItem.resort, let resortCode = resort.resortCode, let exchangeInventory = inventoryItem.inventory {
                    for exchangeBucket in exchangeInventory.buckets {
                        if let unit = exchangeBucket.unit {
                            unit.vacationSearchType = VacationSearchType.EXCHANGE
                        }
                    }
                    
                    if self.searchContext.hasOutResortCodes() && self.searchContext.response.resortCodes.contains(resortCode) {
                        availability[resortCode] = inventoryItem
                    }
                }
            }
        }
        
        var items = [AvailabilitySectionItem]()
        for exchangeAvailability in availability.values {
            items.append(AvailabilitySectionItem(exchangeAvailability: exchangeAvailability))
        }
        
        return items
    }

    private func sortSectionsByDefault(sections:[AvailabilitySection]) -> [AvailabilitySection] {
        // Sort Resorts
        for section in sections {
            // Rule 1: Resort Name (alphabetical: A -> Z)
            section.items.sort(by: {$0.exchangeAvailability?.resort?.resortName?.localizedCaseInsensitiveCompare(
                ($1.exchangeAvailability?.resort?.resortName!)!) == ComparisonResult.orderedAscending})
            
            // Rule 2: TrackCode Category (highest TrackCode weight value within available resort units)
            section.items.sort(by: {self.resolveHighestTrackCode($0.exchangeAvailability!) > self.resolveHighestTrackCode($1.exchangeAvailability!)})

            // Sort Buckets
            self.sortBuckets(section)
        }
        
        return sections
    }

    private func sortSections(sortType:AvailabilitySortType, sections:[AvailabilitySection]) -> [AvailabilitySection] {
        // Sort Resorts
        if sortType.isResortNameAsc() {
            for section in sections {
                // Resort Name (alphabetical: A -> Z)
                section.items.sort(by: {$0.exchangeAvailability?.resort?.resortName?.localizedCaseInsensitiveCompare(
                    ($1.exchangeAvailability?.resort?.resortName!)!) == ComparisonResult.orderedAscending})
                // Sort Buckets
                self.sortBuckets(section)
            }
        } else if sortType.isResortNameDesc() {
            for section in sections {
                // Resort Name (alphabetical: Z -> A)
                section.items.sort(by: {$1.exchangeAvailability?.resort?.resortName?.localizedCaseInsensitiveCompare(
                    ($0.exchangeAvailability?.resort?.resortName!)!) == ComparisonResult.orderedAscending})
                // Sort Buckets
                self.sortBuckets(section)
            }
        } else if sortType.isCityNameAsc() {
            for section in sections {
                // City Name (alphabetical: A -> Z)
                section.items.sort(by: {$0.exchangeAvailability?.resort?.address?.cityName?.localizedCaseInsensitiveCompare(
                    ($1.exchangeAvailability?.resort?.address?.cityName!)!) == ComparisonResult.orderedAscending})
                // Sort Buckets
                self.sortBuckets(section)
            }
        } else if sortType.isCityNameDesc() {
            for section in sections {
                // City Name (alphabetical: Z -> A)
                section.items.sort(by: {$1.exchangeAvailability?.resort?.address?.cityName?.localizedCaseInsensitiveCompare(
                    ($0.exchangeAvailability?.resort?.address?.cityName!)!) == ComparisonResult.orderedAscending})
                // Sort Buckets
                self.sortBuckets(section)
            }
        } else if sortType.isResortTierHighToLow() {
            for section in sections {
                // Resort Tier (highest Tier weigt value)
                section.items.sort(by: {self.resolveHighestTier(($0.exchangeAvailability?.resort!)!) > self.resolveHighestTier(($1.exchangeAvailability?.resort!)!)})
                // Sort Buckets
                self.sortBuckets(section)
            }
        } else if sortType.isResortTierLowToHigh() {
            for section in sections {
                // Resort Tier (lowest Tier weigt value)
                section.items.sort(by: {self.resolveHighestTier(($0.exchangeAvailability?.resort!)!) < self.resolveHighestTier(($1.exchangeAvailability?.resort!)!)})
                // Sort Buckets
                self.sortBuckets(section)
            }
        }
        
        return sections
    }
    
    private func sortBuckets(_ section:AvailabilitySection) {
        // Sort Buckets
        for item in section.items {
            // Rule A: TrackCode Category (highest TrackCode weight value)
            item.exchangeAvailability?.inventory?.buckets.sort(by: {TrackCodeCategory.fromName(name: $0.trackCodeCategory!).weigth >
                TrackCodeCategory.fromName(name: $1.trackCodeCategory!).weigth})
        }
    }

    private func resolveHighestTrackCode(_ availability:ExchangeAvailability) -> Int {
        var highestTrackCodeWeight = 0
        for bucket in (availability.inventory?.buckets)! {
            let weigth = TrackCodeCategory.fromName(name: bucket.trackCodeCategory!).weigth
            if weigth > highestTrackCodeWeight {
                highestTrackCodeWeight = weigth
            }
        }
        return highestTrackCodeWeight
    }

    private func resolveHighestTier(_ resort:Resort) -> Int {
        var highestTierWeight = 0
        let weigth = Tier.fromName(name: resort.tier!).weigth
        if weigth > highestTierWeight {
            highestTierWeight = weigth
        }
        return highestTierWeight
    }

}

