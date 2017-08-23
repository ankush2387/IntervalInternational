//
//  UserContext.swift
//  LeisureTimePassport
//
//  Created by Ralph Fiol on 12/31/15.
//  Copyright © 2015 Interval International. All rights reserved.
//
import DarwinSDK

class UserContext
{
    static let sharedInstance = UserContext()
    
    var accessToken : DarwinAccessToken?
    var contact : Contact?
    var selectedMembership : Membership?
    var appSettings : Settings?
    
    func signOut() {
        self.contact = nil
        self.accessToken = nil
        self.selectedMembership = nil
    }
}
