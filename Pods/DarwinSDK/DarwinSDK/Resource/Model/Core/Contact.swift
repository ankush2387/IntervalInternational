//
//  Profile.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/3/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Contact {
    
	open var contactId : Int64
    open var firstName : String?
    open var lastName : String?
    open var userName : String?
    open var passwordHint : String?
    open var emailAddress : String?
    open var lastVerifiedDate : Date?
    open var enterpriseCode : String?
    open var lockIndicator : Bool?
    open var orgName : String?
    open var creditcards : [Creditcard]?
    open var memberships : [Membership]?
    open var phones : [Phone]?
    open var addresses : [Address]?
	open var status : String?
    open var isPrimary : Bool?
	
	public init() {
        self.contactId = 0
	}
	
	public init(json:JSON) {
		self.contactId = json["contactId"].int64Value
        self.firstName = json["firstName"].string
        self.lastName = json["lastName"].string
		self.userName = json["userName"].string
        self.passwordHint = json["passwordHint"].string
		self.emailAddress = json["email"]["email"].string
        
        if let dateStr = json["lastVerifiedDate"].string {
            self.lastVerifiedDate = dateStr.dateFromLongFormat()
        }
        
		self.enterpriseCode = json["enterpriseCode"].string
		self.lockIndicator = json["lockIndicator"].bool
		self.orgName = json["orgName"].string
		
        if json["creditCards"].exists() {
            let creditcardsArrary:[JSON] = json["creditCards"].arrayValue
            self.creditcards = creditcardsArrary.map { Creditcard(json:$0) }
        }
		
		if json["memberships"].exists() {
			let membershipsArrary:[JSON] = json["memberships"].arrayValue
            self.memberships = membershipsArrary.map { Membership(json:$0) }
        }
        
		if json["telephones"].exists() {
			let phonesArrary:[JSON] = json["telephones"].arrayValue
            self.phones = phonesArrary.map { Phone(json:$0) }
		}

		if json["postalAddresses"].exists() {
			let addressArrary:[JSON] = json["postalAddresses"].arrayValue
            self.addresses = addressArrary.map { Address(json:$0) }
        }
        
        self.status = json["status"]["code"].string
        
        if let value = json["isPrimary"].bool {
            self.isPrimary = value
        }
	}
    
	open func isActive() -> Bool {
		if let s = self.status {
			return s == ContactStatus.Active.rawValue
		}
		
		return false  // Unknown
	}

	open func isLocked() -> Bool {
        return self.lockIndicator ?? false
	}

    open func hasMembership() -> Bool {
        return (self.memberships?.count ?? 0) > 0
    }
    
    open func hasAddress() -> Bool {
        return (self.addresses?.count ?? 0) > 0
    }

    open func hasPhone() -> Bool {
        return (self.phones?.count ?? 0) > 0
    }

    open func getAddress(_ type:AddressType) -> Address? {
		if let addressArray = self.addresses {
			for address in addressArray {
				if address.addressType == type.rawValue {
					return address
				}
			}
		}
		
		return nil
	}
    
    open func getPhone(type:PhoneType) -> Phone? {
        if let phoneArray = self.phones {
            for phone in phoneArray {
                if phone.phoneType == type.rawValue {
                    return phone
                }
            }
        }
        
        return nil
    }
	
}
