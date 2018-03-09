//
//  AvailabilitySectionItem.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class AvailabilitySectionItem {
    
    open var rentalAvailability : Resort?
    open var exchangeAvailability : ExchangeAvailability?
    
    public init(rentalAvailability: Resort) {
        self.rentalAvailability = rentalAvailability
    }
    
    public init(exchangeAvailability: ExchangeAvailability) {
        self.exchangeAvailability = exchangeAvailability
    }
    
    open func hasRentalAvailability() -> Bool {
        return self.rentalAvailability != nil
    }
    
    open func hasExchangeAvailability() -> Bool {
        return self.exchangeAvailability != nil
    }
    
    open func getCurrencyCode() -> String? {
        if let rentalResort = self.rentalAvailability, let inventory = rentalResort.inventory, let currencyCode = inventory.currencyCode {
            return currencyCode
        }
        return nil
    }
    
    open func showGeneralUnitSizeUpgradeMessage() -> Bool? {
        if let exchangeAvailability = self.exchangeAvailability, let inventory = exchangeAvailability.inventory {
            return inventory.generalUnitSizeUpgradeMessage
        }
        return nil
    }
    
    open func getResort() -> AvailabilitySectionItemResort? {
        if let rentalResort = self.rentalAvailability {
            return AvailabilitySectionItemResort(code: rentalResort.resortCode ?? "Unknown",
                                                 name: rentalResort.resortName ?? "Unknown",
                                                 tier: Tier.fromName(name: rentalResort.tier),
                                                 address: rentalResort.address,
                                                 rating: rentalResort.rating,
                                                 images: rentalResort.images,
                                                 videos: rentalResort.videos)
        } else  if let exchangeAvailability = self.exchangeAvailability, let exchangeResort = exchangeAvailability.resort {
            return AvailabilitySectionItemResort(code: exchangeResort.resortCode ?? "Unknown",
                                                 name: exchangeResort.resortName ?? "Unknown",
                                                 tier: Tier.fromName(name: exchangeResort.tier),
                                                 address: exchangeResort.address,
                                                 rating: exchangeResort.rating,
                                                 images: exchangeResort.images,
                                                 videos: exchangeResort.videos)
        }
        
        return nil
    }
    
    open func getInventoryBuckets() -> [AvailabilitySectionItemInventoryBucket] {
        var inventoryBuckets: [AvailabilitySectionItemInventoryBucket] = [AvailabilitySectionItemInventoryBucket]()
        
        if let rentalResort = self.rentalAvailability, let inventory = rentalResort.inventory, !inventory.units.isEmpty {
            for unit in inventory.units {
                let inventoryBucketUnit = AvailabilitySectionItemInventoryBucketUnit(unitSize: UnitSize.fromName(name: unit.unitSize),
                                                                                     kitchenType: KitchenType.fromName(name: unit.kitchenType),
                                                                                     publicSleepCapacity: unit.publicSleepCapacity,
                                                                                     privateSleepCapacity: unit.privateSleepCapacity,
                                                                                     platinumScape: unit.platinumScape,
                                                                                     priorityViewing: unit.priorityViewing)
                
                let inventoryBucket = AvailabilitySectionItemInventoryBucket(vacationSearchType: unit.vacationSearchType,
                                                                             trackCodeCategory: TrackCodeCategory.fromName(name: unit.trackCodeCategory),
                                                                             promotions: unit.promotions,
                                                                             unit: inventoryBucketUnit,
                                                                             rentalPrices: unit.prices,
                                                                             exchangePointsCost: nil,
                                                                             exchangeMemberPointsRequired: nil)
                
                inventoryBuckets.append(inventoryBucket)
            }
        }
        
        if let exchangeAvailability = self.exchangeAvailability, let inventory = exchangeAvailability.inventory, !inventory.buckets.isEmpty {
            for bucket in inventory.buckets {
                if let unit = bucket.unit {
                    let inventoryBucketUnit = AvailabilitySectionItemInventoryBucketUnit(unitSize: UnitSize.fromName(name: unit.unitSize),
                                                                                         kitchenType: KitchenType.fromName(name: unit.kitchenType),
                                                                                         publicSleepCapacity: unit.publicSleepCapacity,
                                                                                         privateSleepCapacity: unit.privateSleepCapacity,
                                                                                         platinumScape: unit.platinumScape,
                                                                                         priorityViewing: unit.priorityViewing);
                    
                    let inventoryBucket = AvailabilitySectionItemInventoryBucket(vacationSearchType: unit.vacationSearchType,
                                                                                 trackCodeCategory: TrackCodeCategory.fromName(name: bucket.trackCodeCategory),
                                                                                 promotions: bucket.promotions,
                                                                                 unit: inventoryBucketUnit,
                                                                                 rentalPrices: nil,
                                                                                 exchangePointsCost: bucket.pointsCost,
                                                                                 exchangeMemberPointsRequired: bucket.memberPointsRequired)
                    
                    inventoryBuckets.append(inventoryBucket)
                }
            }
        }
        
        return inventoryBuckets
    }
    
}

public struct AvailabilitySectionItemResort {
    let code: String
    let name: String
    let tier: Tier
    let address: Address?
    let rating: ResortRating?
    let images: [Image]
    let videos: [Video]
}

public struct AvailabilitySectionItemInventoryBucket {
    let vacationSearchType: VacationSearchType
    let trackCodeCategory: TrackCodeCategory
    let promotions: [Promotion]
    let unit: AvailabilitySectionItemInventoryBucketUnit
    let rentalPrices: [InventoryPrice]?
    let exchangePointsCost: Int?
    let exchangeMemberPointsRequired: Int?
}

public struct AvailabilitySectionItemInventoryBucketUnit {
    let unitSize: UnitSize
    let kitchenType: KitchenType
    let publicSleepCapacity: Int
    let privateSleepCapacity: Int
    let platinumScape: Bool
    let priorityViewing: Bool
}

