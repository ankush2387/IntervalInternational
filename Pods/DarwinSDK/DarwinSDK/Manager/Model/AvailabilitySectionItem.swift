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
            return AvailabilitySectionItemResort(code: rentalResort.resortCode ?? "",
                                                 name: rentalResort.resortName ?? "",
                                                 tier: Tier.fromName(name: rentalResort.tier),
                                                 address: rentalResort.address,
                                                 rating: rentalResort.rating,
                                                 images: rentalResort.images,
                                                 videos: rentalResort.videos,
                                                 allInclusive: rentalResort.allInclusive)
        } else  if let exchangeAvailability = self.exchangeAvailability, let exchangeResort = exchangeAvailability.resort {
            return AvailabilitySectionItemResort(code: exchangeResort.resortCode ?? "",
                                                 name: exchangeResort.resortName ?? "",
                                                 tier: Tier.fromName(name: exchangeResort.tier),
                                                 address: exchangeResort.address,
                                                 rating: exchangeResort.rating,
                                                 images: exchangeResort.images,
                                                 videos: exchangeResort.videos,
                                                 allInclusive: exchangeResort.allInclusive)
        }
        return nil
    }
    
    open func getInventoryBuckets() -> [AvailabilitySectionItemInventoryBucket]? {
        var inventoryBuckets = [String: AvailabilitySectionItemInventoryBucket]()
        
        if let rentalResort = self.rentalAvailability, let inventory = rentalResort.inventory, !inventory.units.isEmpty {
            for unit in inventory.units {
                let inventoryBucketUnit = AvailabilitySectionItemInventoryBucketUnit(unitSize: UnitSize.fromName(name: unit.unitSize),
                                                                                     kitchenType: KitchenType.fromName(name: unit.kitchenType),
                                                                                     publicSleepCapacity: unit.publicSleepCapacity,
                                                                                     privateSleepCapacity: unit.privateSleepCapacity,
                                                                                     platinumScape: unit.platinumScape,
                                                                                     priorityViewing: unit.priorityViewing)
                
                let inventoryBucket = AvailabilitySectionItemInventoryBucket(key: inventoryBucketUnit.generateKey(),
                                                                             vacationSearchType: unit.vacationSearchType,
                                                                             trackCodeCategory: TrackCodeCategory.fromName(name: unit.trackCodeCategory),
                                                                             checkInDate: inventory.checkInDate!,
                                                                             checkOutDate: inventory.checkOutDate!,
                                                                             unit: inventoryBucketUnit,
                                                                             promotions: unit.promotions,
                                                                             rentalPrices: unit.prices,
                                                                             currencyCode: inventory.currencyCode,
                                                                             exchangePointsCost: nil,
                                                                             exchangeMemberPointsRequired: nil)
                
                inventoryBuckets[inventoryBucket.key] = inventoryBucket
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
                    
                    let inventoryBucket = AvailabilitySectionItemInventoryBucket(key: inventoryBucketUnit.generateKey(),
                                                                                 vacationSearchType: unit.vacationSearchType,
                                                                                 trackCodeCategory: TrackCodeCategory.fromName(name: bucket.trackCodeCategory),
                                                                                 checkInDate: inventory.checkInDate!,
                                                                                 checkOutDate: inventory.checkOutDate!,
                                                                                 unit: inventoryBucketUnit,
                                                                                 promotions: bucket.promotions,
                                                                                 rentalPrices: nil,
                                                                                 currencyCode: nil,
                                                                                 exchangePointsCost: bucket.pointsCost,
                                                                                 exchangeMemberPointsRequired: bucket.memberPointsRequired)
                    
                    if var bucket = inventoryBuckets[inventoryBucket.key] {
                        bucket.vacationSearchType = VacationSearchType.COMBINED
                        bucket.exchangePointsCost = inventoryBucket.exchangePointsCost
                        bucket.exchangeMemberPointsRequired = inventoryBucket.exchangeMemberPointsRequired
                        inventoryBuckets[inventoryBucket.key] = bucket
                    } else {
                        inventoryBuckets[inventoryBucket.key] = inventoryBucket
                    }
                }
            }
        }
        
        var buckets = [AvailabilitySectionItemInventoryBucket]()
        buckets.append(contentsOf: inventoryBuckets.values)
    
        if buckets.isEmpty {
            return nil
        } else {
            return buckets
        }
    }
    
}

public struct AvailabilitySectionItemResort {
    public let code: String
    public let name: String
    public let tier: Tier
    public let address: Address?
    public let rating: ResortRating?
    public let images: [Image]
    public let videos: [Video]
    public let allInclusive: Bool
    
    public func getDefaultImage(_ size:ImageSize) -> Image? {
        return self.images.filter { $0.size == size.rawValue }.first
    }
   
    public func getDefaultImage() -> Image? {
        if let image = getDefaultImage(ImageSize.XLARGE) {
            return image
        } else if let image = getDefaultImage(ImageSize.LARGE) {
            return image
        } else if let image = getDefaultImage(ImageSize.THUMBNAIL) {
            return image
        } else if let image = getDefaultImage(ImageSize.TYNY) {
            return image
        } else {
            return nil
        }
    }

}

public struct AvailabilitySectionItemInventoryBucket {
    public let key: String
    public var vacationSearchType: VacationSearchType
    public let trackCodeCategory: TrackCodeCategory
    public let checkInDate: String
    public let checkOutDate: String
    public let unit: AvailabilitySectionItemInventoryBucketUnit
    public let promotions: [Promotion]?
    public let rentalPrices: [InventoryPrice]?
    public let currencyCode: String?
    public var exchangePointsCost: Int?
    public var exchangeMemberPointsRequired: Int?
}

public struct AvailabilitySectionItemInventoryBucketUnit {
    public let unitSize: UnitSize
    public let kitchenType: KitchenType
    public let publicSleepCapacity: Int
    public let privateSleepCapacity: Int
    public let platinumScape: Bool
    public let priorityViewing: Bool
    
    public func generateKey() -> String {
        var key = ""
        key += unitSize.rawValue
        key += kitchenType.rawValue
        key += "\(publicSleepCapacity)"
        key += "\(privateSleepCapacity)"
        return key
    }
}

