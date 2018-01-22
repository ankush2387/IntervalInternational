//
//  RentalSearch.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class RentalSearch {
    
    open var searchContext : RentalSearchContext
    open var resortNames : [String]?
    open var areaName : String?
    open var inventory : [Resort]?
    
    public init(_ searchCriteria:VacationSearchCriteria, _ bookingWindow:BookingWindow) {
        if let activeInterval = bookingWindow.getActiveInterval() {
            let request = RentalSearchDatesRequest()
            request.checkInFromDate = activeInterval.startDate
            request.checkInToDate = activeInterval.endDate
            
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

            self.searchContext = RentalSearchContext(request: request)
        } else {
            // TODO(Frank): Should never happen
            self.searchContext = RentalSearchContext(request: RentalSearchDatesRequest())
        }
    }
    
    /*
    open func hasInventory() -> Bool {
        guard let list = inventory else { return false }
        return !list.isEmpty
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
                    var exactMatchRentalInventory = [String: Resort]()
                    var surroundingMatchRentalInventory = [String: Resort]()
                    
                    // Grouping buckets into sections: Exact, Surrounding
                    for inventoryItem in inventory {
                        if let resortCode = inventoryItem.resortCode, let rentalInventory = inventoryItem.inventory {
                            for rentalBucket in rentalInventory.units {
                                rentalBucket.vacationSearchType = VacationSearchType.RENTAL
                            }
                            
                            if self.searchContext.hasOutResortCodes() && self.searchContext.response.resortCodes.contains(resortCode) {
                                exactMatchRentalInventory[resortCode] = inventoryItem
                            }

                            if self.searchContext.hasOutSurroundingResortCodes() && self.searchContext.response.surroundingResortCodes.contains(resortCode) {
                                surroundingMatchRentalInventory[resortCode] = inventoryItem
                            }
                        }
                    }
                    
                    if !exactMatchRentalInventory.isEmpty {
                        // Buckets should be show up into the Exact Match section for each Destination.
                        var items = [AvailabilitySectionItem]()
                        for rentalAvailability in exactMatchRentalInventory.values {
                            items.append(AvailabilitySectionItem(rentalAvailability: rentalAvailability))
                        }
                        sections.append(AvailabilitySection(items: items, destination: destination, exactMatch: true))
                    }
                    
                    if !surroundingMatchRentalInventory.isEmpty {
                        // Buckets should be show up into the Surrounding Match section for each Destination.
                        var items = [AvailabilitySectionItem]()
                        for rentalAvailability in surroundingMatchRentalInventory.values {
                            items.append(AvailabilitySectionItem(rentalAvailability: rentalAvailability))
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
        var resorts = [String: Resort]()

        if let inventory = self.inventory {
            for inventoryItem in inventory {
                if let resortCode = inventoryItem.resortCode, let rentalInventory = inventoryItem.inventory {
                    for rentalBucket in rentalInventory.units {
                        rentalBucket.vacationSearchType = VacationSearchType.RENTAL
                    }
                    
                    if self.searchContext.hasOutResortCodes() && self.searchContext.response.resortCodes.contains(resortCode) {
                        resorts[inventoryItem.resortCode!] = inventoryItem
                    }
                }
            }
        }

        var items = [AvailabilitySectionItem]()
        for rentalAvailability in resorts.values {
            items.append(AvailabilitySectionItem(rentalAvailability: rentalAvailability))
        }

        return items
    }

    private func sortSectionsByDefault(sections:[AvailabilitySection]) -> [AvailabilitySection] {
        // Sort Resorts
        for section in sections {
            // Rule 1: Price (low to high)
            section.items.sort(by: {self.resolveHighestPrice($0.rentalAvailability!) < self.resolveHighestPrice($1.rentalAvailability!)})
            
            // Rule 2: Resort Name (alphabetical: A -> Z)
            section.items.sort(by: {$0.rentalAvailability?.resortName?.localizedCaseInsensitiveCompare(
                ($1.rentalAvailability?.resortName!)!) == ComparisonResult.orderedAscending})
            
            // Rule 3: TrackCode Category (highest TrackCode weight value within available resort units)
            section.items.sort(by: {self.resolveHighestTrackCode($0.rentalAvailability!) > self.resolveHighestTrackCode($1.rentalAvailability!)})
            
            // Sort Units
            self.sortUnits(section)
        }
        return sections
    }

    private func sortSections(sortType:AvailabilitySortType, sections:[AvailabilitySection]) -> [AvailabilitySection] {
        // Sort Resorts
        if sortType.isResortNameAsc() {
            for section in sections {
                // Resort Name (alphabetical: A -> Z)
                section.items.sort(by: {$0.rentalAvailability?.resortName?.localizedCaseInsensitiveCompare(
                    ($1.rentalAvailability?.resortName!)!) == ComparisonResult.orderedAscending})
                // Sort Units
                self.sortUnits(section)
            }
        } else if sortType.isResortNameDesc() {
            for section in sections {
                // Resort Name (alphabetical: Z -> A)
                section.items.sort(by: {$1.rentalAvailability?.resortName?.localizedCaseInsensitiveCompare(
                    ($0.rentalAvailability?.resortName!)!) == ComparisonResult.orderedAscending})
                // Sort Units
                self.sortUnits(section)
            }
        } else if sortType.isCityNameAsc() {
            for section in sections {
                // City Name (alphabetical: A -> Z)
                section.items.sort(by: {$0.rentalAvailability?.address?.cityName?.localizedCaseInsensitiveCompare(
                    ($1.rentalAvailability?.address?.cityName!)!) == ComparisonResult.orderedAscending})
                // Sort Units
                self.sortUnits(section)
            }
        } else if sortType.isCityNameDesc() {
            for section in sections {
                // City Name (alphabetical: Z -> A)
                section.items.sort(by: {$1.rentalAvailability?.address?.cityName?.localizedCaseInsensitiveCompare(
                    ($0.rentalAvailability?.address?.cityName!)!) == ComparisonResult.orderedAscending})
                // Sort Units
                self.sortUnits(section)
            }
        } else if sortType.isResortTierHighToLow() {
            for section in sections {
                // Resort Tier (highest Tier weigt value)
                section.items.sort(by: {self.resolveHighestTier($0.rentalAvailability!) > self.resolveHighestTier($1.rentalAvailability!)})
                // Sort Units
                self.sortUnits(section)
            }
        } else if sortType.isResortTierLowToHigh() {
            for section in sections {
                // Resort Tier (lowest Tier weigt value)
                section.items.sort(by: {self.resolveHighestTier($0.rentalAvailability!) < self.resolveHighestTier($1.rentalAvailability!)})
                // Sort Units
                self.sortUnits(section)
            }
        } else if sortType.isPriceHighToLow() {
            for section in sections {
                // Price (high to low)
                section.items.sort(by: {self.resolveHighestPrice($0.rentalAvailability!) > self.resolveHighestPrice($1.rentalAvailability!)})
                // Sort Units
                self.sortUnits(section)
            }
        } else if sortType.isPriceLowToHigh() {
            for section in sections {
                // Price (low to high)
                section.items.sort(by: {self.resolveHighestPrice($0.rentalAvailability!) < self.resolveHighestPrice($1.rentalAvailability!)})
                // Sort Units
                self.sortUnits(section)
            }
        }
        
        return sections
    }
    
    private func sortUnits(_ section:AvailabilitySection) {
        // Sort Units
        for item in section.items {
            // Rule A: TrackCode Category (highest TrackCode weight value)
            item.rentalAvailability?.inventory?.units.sort(by: {TrackCodeCategory.fromName(name: $0.trackCodeCategory!).weigth >
                TrackCodeCategory.fromName(name: $1.trackCodeCategory!).weigth})
        }
    }

    private func resolveHighestTrackCode(_ resort:Resort) -> Int {
        var highestTrackCodeWeight = 0
        for unit in (resort.inventory?.units)! {
            let weigth = TrackCodeCategory.fromName(name: unit.trackCodeCategory!).weigth
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
    
    private func resolveHighestPrice(_ resort:Resort) -> Float {
        var highestPrice : Float = 0.0
        if (resort.inventory?.priceFrom)! > highestPrice {
            highestPrice = resort.inventory!.priceFrom
        }
        return highestPrice
    }
 
}
