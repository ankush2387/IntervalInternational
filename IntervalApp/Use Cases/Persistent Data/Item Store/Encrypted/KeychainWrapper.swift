//
//  KeychainWrapper.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/31/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import KeychainAccess

struct KeychainWrapper {
    // MARK: - Private properties
    fileprivate let keychain = Keychain(service: Persistent.bundleIdentifier.key)

    fileprivate func saveToKeychain<T: Hashable>(_ item: T, for key: String, and contactID: String = "") throws {

        switch item {

        case is String:
            if let item = item as? String {
                return try keychain.set(item as String, key: key + contactID)
            } else {
                throw CommonErrors.parsingError
            }

        case is Int:
            if let item = item as? Int {
                return try keychain.set(String(item), key: key + contactID)
            } else {
                throw CommonErrors.parsingError
            }

        case is Double:
            if let item = item as? Double {
                return try keychain.set(String(item), key: key + contactID)
            } else {
                throw CommonErrors.parsingError
            }

        case is Bool:
            if let item = item as? Bool {
                return try keychain.set(String(item), key: key + contactID)
            } else {
                throw CommonErrors.parsingError
            }

        case is Data:
            if let item = item as? Data {
                return try keychain.set(item, key: key + contactID)
            } else {
                throw CommonErrors.parsingError
            }

        default:
            throw CommonErrors.unsupportedData
        }
    }

    fileprivate func getItemFromKeychain<T: Hashable>(for key: String, and contactID: String = "", ofType: T) throws -> T? {

        switch ofType {

        case is String:
            if let item = try? keychain.get(key + contactID) {
                return item as? T
            } else {
                throw CommonErrors.parsingError
            }

        case is Int:
            if let item = try? keychain.get(key + contactID), let stringRepresentation = item, let doubleRepresentation = Double(stringRepresentation) {
                return Int(doubleRepresentation) as? T
            } else {
                throw CommonErrors.parsingError
            }

        case is Double:
            if let item = try? keychain.get(key + contactID), let stringRepresentation = item {
                return Double(stringRepresentation) as? T
            } else {
                throw CommonErrors.parsingError
            }

        case is Bool:
            if let item = try? keychain.get(key + contactID), let stringRepresentation = item {
                return (stringRepresentation == "true") as? T
            } else {
                throw CommonErrors.parsingError
            }

        case is Data:
            if let item = try? keychain.getData(key + contactID) {
                return item as? T
            } else {
                throw CommonErrors.parsingError
            }

        default:
            throw CommonErrors.unsupportedData
        }
    }
}

extension KeychainWrapper: EncryptedStore {

    func save<T: Hashable>(item: T, for key: String) throws {
        return try saveToKeychain(item, for: key)
    }

    func save<T: Hashable>(item: T, for key: String, and contactID: String) throws {
        return try saveToKeychain(item, for: key, and: contactID)
    }

    func getItem<T: Hashable>(for key: String, ofType: T) throws -> T? {
        return try getItemFromKeychain(for: key, ofType: ofType)
    }

    func getItem<T: Hashable>(for key: String, and contactID: String, ofType: T) throws -> T? {
        return try getItemFromKeychain(for: key, and: contactID, ofType: ofType)
    }
}
