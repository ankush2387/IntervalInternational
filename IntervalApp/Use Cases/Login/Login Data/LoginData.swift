//
//  LoginData.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/13/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import KeychainAccess

struct LoginData: EncryptedStore {
    
    // MARK: - Private properties
    private let keychain = Keychain(service: Persistent.bundleIdentifier.key)
    
    func save(item: String, for key: String) throws {
        return try keychain.set(item, key: key)
    }
    
    func getItem(for key: String) throws -> String? {
        return try keychain.get(key)
    }
}
