//
//  IntervalHelper.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 2/16/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

open class IntervalHelper {
    
    // Get the best rental price based on current membership
    //
    open static func getBestRentalPrice( _ currentMembership: Membership, prices: [InventoryPrice]?) -> InventoryPrice? {
        return getBestRentalPrice(self.getProductCodeFromHighestTier(products: currentMembership.products), prices: prices)
    }
    
    // Get the best rental price based on productCodeFromHighestTier in the current membership
    //
    open static func getBestRentalPrice( _ productCodeFromHighestTier: String?, prices: [InventoryPrice]?) -> InventoryPrice? {
        if let productCodeFromHighestTierValue = productCodeFromHighestTier, let rentalPrices = prices, !rentalPrices.isEmpty {
            for rentalPrice in rentalPrices {
                if productCodeFromHighestTierValue == rentalPrice.productCode {
                    return rentalPrice
                }
            }
        }
        return nil
    }
    
    // Get the productCodeFromHighestTier
    //
    open static func getProductCodeFromHighestTier(products: [Product]?) -> String? {
        if let membershipProducts = products {
            for membershipProduct in membershipProducts {
                if membershipProduct.highestTier {
                    return membershipProduct.productCode
                }
            }
        }
        return nil
    }
    
}

