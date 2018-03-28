//
//  Membership.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/7/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Membership {
    
	open var memberNumber : String?
    open var sinceDate : Date?
    open var membershipTypeCode : String?
    open var membershipResortCode : String?
    open var products : [Product]?
	open var ownerships : [Ownership]?
    open var contacts : [Contact]?
    
	public init() {
	}

    public init(json:JSON) {
        self.memberNumber = json["number"].string
        
        if let dateStr = json["sinceDate"].string {
            self.sinceDate = dateStr.dateFromShortFormat()
        }
        
        self.membershipTypeCode = json["membershipTypeCode"].string
        self.membershipResortCode = json["membershipResortCode"].string
        
		if json["membershipProducts"].exists() {
        	let productsArrary:[JSON] = json["membershipProducts"].arrayValue
            self.products = productsArrary.map { Product(json:$0) }
        }

		if json["ownerships"].exists() {
			let ownershipsArrary:[JSON] = json["ownerships"].arrayValue
            self.ownerships = ownershipsArrary.map { Ownership(json:$0) }
        }
        
        if json["contacts"].exists() {
            let contactsArrary:[JSON] = json["contacts"].arrayValue
            self.contacts = contactsArrary.map { Contact(json:$0) }
        }
    }
    
    open func getProductCount() -> Int {
        return (self.products?.count ?? 0)
    }
        
    open func hasProduct() -> Bool {
        return (self.products?.count ?? 0) > 0
    }

    open func hasOwnership() -> Bool {
        return (self.ownerships?.count ?? 0) > 0
    }
    
    open func hasContact() -> Bool {
        return (self.contacts?.count ?? 0) > 0
    }
    
    open func getProductWithHighestTier() -> Product? {

        if let productsArray = self.products {
            
            for product in productsArray {
                if product.highestTier == true {
                    return product
                }
            }
            
            // If we get here, them there is a servic problem.  There should always be one product marked as
            // the highest tier.  Handle this by just returning the last product.
            DarwinSDK.logger.warning("There is no product marked with highestTier=true for membership \(self.memberNumber ?? "0")")
            
            if productsArray.count == 0 {
                return nil
            }
            
            return productsArray[ productsArray.count - 1 ]
        }
        
        return nil
    }
    
}
