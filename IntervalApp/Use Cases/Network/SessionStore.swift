//
//  SessionStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/13/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import DarwinSDK

protocol SessionStore {
    var contactID: String { get }
    var contact: Contact? { get set }
    var appSettings: Settings? { get set }
    var selectedMembership: Membership? { get set }
    var clientAccessToken: DarwinAccessToken? { get set }
    var userAccessToken: DarwinAccessToken? { get set }
}
