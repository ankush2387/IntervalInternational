//
//  UserClientAPIStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/21/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import then
import DarwinSDK
import Foundation

protocol UserClientAPIStore {
    func readCurrentProfile(for accessToken: DarwinAccessToken) -> Promise<Contact>
    func readMembership(for accessToken: DarwinAccessToken, and membershipNumber: String) -> Promise<Membership>
}
