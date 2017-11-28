//
//  Phone.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/3/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Phone {
    
	open var phoneId : Int64 = 0
	open var phoneType : String?
	open var countryCode : String?
	open var countryPhoneCode : String?
	open var areaCode : String?
	open var phoneNumber : String?
	open var extensionNumber : String?
	open var status : String?
	open var usagePriorityCode : String?
	open var cellTermsAcceptedInd : Bool?
	open var cellTermsAcceptedPrompt : Bool?
	open var doNotCallInd : Bool?
	
	public init() {
	}

	public init(json:JSON) {
		self.phoneId = json["phoneId"].int64Value
		self.phoneType = json["type"].string
		self.countryCode = json["countryCode"].string
		self.countryPhoneCode = json["countryPhoneCode"].string
		self.areaCode = json["areaCode"].string
		self.phoneNumber = json["telephoneNumber"].string
		self.extensionNumber = json["extensionNumber"].string
		self.status = json["status"].string
		self.usagePriorityCode = json["usagePriorityCode"].string
		self.cellTermsAcceptedInd = json["cellTermsAcceptanceInd"].boolValue
		self.cellTermsAcceptedPrompt = json["cellTermsAcceptancePrompt"].boolValue
		self.doNotCallInd = json["doNotCallInd"].boolValue
	}
    
    open func phoneNumberString() -> String {
        
        var sep = false
        var s = ""
        
        if (self.areaCode?.characters.count)! > 0 {
            s += ("(" + self.areaCode! + ")")
            sep = true
        }
        
        if (self.phoneNumber?.characters.count)! > 0 {
            s += (sep == true ? " " : "")
            
            if (self.phoneNumber?.characters.count)! > 6 {
                let p = self.phoneNumber!
				
				s += p.substring(to: s.index(s.startIndex, offsetBy: 3) )
                s += "-"
				s += p.substring(from: s.index(s.startIndex, offsetBy: 3) )
                
            }
            else {
                s += self.phoneNumber!
            }
            
            sep = true
        }
        
        if (self.extensionNumber?.characters.count)! > 0 && self.extensionNumber != "0" {
            s += (sep == true ? " x" : "x")
            s += self.extensionNumber!
            sep = true
        }
        
        return s
    }
    
    open func toDictionary() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        dictionary["type"] = phoneType as AnyObject?
        dictionary["countryPhoneCode"] = countryPhoneCode as AnyObject?
        dictionary["areaCode"] = areaCode as AnyObject?
        dictionary["countryCode"] = countryCode as AnyObject?
        dictionary["telephoneNumber"] = phoneNumber as AnyObject?
        dictionary["extensionNumber"] = extensionNumber as AnyObject?
        return dictionary
    }
    
}
