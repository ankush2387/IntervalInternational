//
//  Session.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import DarwinSDK

// MARK: - Lazy properties
// Global `lazy` properties will only set once during app session
// Workaround - Entire app is using singleton
private var clientToken: DarwinAccessToken?
private var userToken: DarwinAccessToken?

final class Session: SessionStore {
    
    // MARK: - Public properties
    static let sharedSession = Session()

    var contact: Contact?
    var appSettings: Settings?
    var selectedMembership: Membership?

    var clientAccessToken: DarwinAccessToken? {
        get { return clientToken }
        set { clientToken = newValue }
    }

    var userAccessToken: DarwinAccessToken? {
        get { return userToken }
        set { userToken = newValue }
    }
    
    // TODO: - Move this to the login coordinator
    func signOut() {
        self.contact = nil
        self.userAccessToken = nil
        self.selectedMembership = nil
    }
}
