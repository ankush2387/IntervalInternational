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
        if let productCodeFromHighestTier = self.getProductCodeFromHighestTier(products: currentMembership.products), let rentalPrices = prices {
            for rentalPrice in rentalPrices {
                if productCodeFromHighestTier == rentalPrice.productCode {
                    return rentalPrice
                }
            }
        }
        return nil
    }
    
    fileprivate static func getProductCodeFromHighestTier(products: [Product]?) -> String? {
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
