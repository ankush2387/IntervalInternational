//
//  Keychain.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/31/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

struct Keychain {

    // MARK: - Private properties
    private let service: String

    private enum KeychainError: Error {
        case itemNotFound
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }

    // MARK: - Lifecycle
    init(service: String = Persistent.bundleIdentifier.key) {
        self.service = service
    }

    // MARK: - Fileprivate functions
    fileprivate func saveToKeychain<T>(_ item: T, for key: String, and contactID: String = "") throws {

        var itemData: Data?

        switch item {

        case is String:
            if let item = item as? String {
                itemData = item.data(using: String.Encoding.utf8)
            } else {
                throw CommonErrors.parsingError
            }

        case is Int:
            if let item = item as? Int {
                itemData = String(item).data(using: String.Encoding.utf8)
            } else {
                throw CommonErrors.parsingError
            }

        case is Double:
            if let item = item as? Double {
                itemData = String(item).data(using: String.Encoding.utf8)
            } else {
                throw CommonErrors.parsingError
            }

        case is Bool:
            if let item = item as? Bool {
                itemData = String(item).data(using: String.Encoding.utf8)
            } else {
                throw CommonErrors.parsingError
            }

        case is Dictionary<AnyHashable, Any>:
            if let item = item as? Dictionary<AnyHashable, Any> {
                itemData = NSKeyedArchiver.archivedData(withRootObject: item)
            } else {
                throw CommonErrors.parsingError
            }

        case is Array<Any>:
            if let item = item as? Array<Any> {
                itemData = NSKeyedArchiver.archivedData(withRootObject: item)
            } else {
                throw CommonErrors.parsingError
            }

        case is Set<AnyHashable>:
            if let item = item as? Set<AnyHashable> {
                itemData = NSKeyedArchiver.archivedData(withRootObject: item)
            } else {
                throw CommonErrors.parsingError
            }

        case is Data:
            itemData = item as? Data

        default:
            throw CommonErrors.unsupportedData
        }

        try save(itemData, for: key, and: contactID)
    }

    fileprivate func getItemFromKeychain<T>(for key: String, and contactID: String = "", ofType: T) throws -> T? {

        var queryResult: AnyObject?
        let status = read(for: key, and: contactID, save: &queryResult)

        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.itemNotFound }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        var stringRepresentation: String? {

            guard let item = queryResult as? [String: AnyObject], let itemData = item[kSecValueData as String] as? Data else {
                return nil
            }

            return String(data: itemData, encoding: String.Encoding.utf8)
        }

        var dataRepresentation: Data? {

            guard let item = queryResult as? [String: AnyObject], let itemData = item[kSecValueData as String] as? Data else {
                return nil
            }

            return itemData
        }

        switch ofType {

        case is String:
            if let item = stringRepresentation {
                return item as? T
            } else {
                throw CommonErrors.parsingError
            }

        case is Int:
            if let item = stringRepresentation, let doubleRepresentation = Double(item) {
                return Int(doubleRepresentation) as? T
            } else {
                throw CommonErrors.parsingError
            }

        case is Double:
            if let item = stringRepresentation {
                return Double(item) as? T
            } else {
                throw CommonErrors.parsingError
            }

        case is Bool:
            if let item = stringRepresentation {
                return (item == "true") as? T
            } else {
                throw CommonErrors.parsingError
            }

        case is Dictionary<AnyHashable, Any>, is Array<Any>, is Set<AnyHashable>:
            if let item = dataRepresentation {
                return NSKeyedUnarchiver.unarchiveObject(with: item) as? T
            } else {
                throw CommonErrors.parsingError
            }

        case is Data:
            if let item = dataRepresentation {
                return item as? T
            } else {
                throw CommonErrors.parsingError
            }

        default:
            throw CommonErrors.unsupportedData
        }
    }

    // MARK: - Private functions
    private func save(_ data: Data?, for key: String, and contactID: String = "") throws {
        do {
            var queryResult: AnyObject?
            let status = read(for: key, and: contactID, save: &queryResult)
            // Check the return status and throw an error if appropriate.
            guard status != errSecItemNotFound else { throw KeychainError.itemNotFound }
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
            // try to update item on Disk if it exists
            try update(data, for: key, and: contactID)
        } catch {
            // If item has not been previously created - write item to disk
            try write(data, for: key, and: contactID)
        }
    }

    private func write(_ data: Data?, for key: String, and contactID: String = "") throws {
        guard let data = data else { throw CommonErrors.nilDataError }
        var query = keychainQuery(with: key, and: contactID)
        query[kSecValueData as String] = data as AnyObject
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
    }

    private func read(for key: String, and contactID: String = "", save queryResult: inout AnyObject?) -> OSStatus {
        var query = keychainQuery(with: key, and: contactID)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        return withUnsafeMutablePointer(to: &queryResult) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
    }

    private func update(_ data: Data?, for key: String, and contactID: String = "") throws {
        guard let data = data else { throw CommonErrors.nilDataError }
        var attributesToSave = [String : AnyObject]()
        attributesToSave[kSecValueData as String] = data as AnyObject
        let query = keychainQuery(with: key, and: contactID)
        let status = SecItemUpdate(query as CFDictionary, attributesToSave as CFDictionary)
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
    }

    private func keychainQuery(with key: String, and contactID: String) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject
        query[kSecAttrAccount as String] = key + contactID as AnyObject
        return query
    }
}

extension Keychain: EncryptedItemDataStore {

    func save<T>(item: T, for key: String) throws {
        return try saveToKeychain(item, for: key)
    }

    func save<T>(item: T, for key: String, and contactID: String) throws {
        return try saveToKeychain(item, for: key, and: contactID)
    }

    func getItem<T>(for key: String, ofType: T) throws -> T? {
        return try getItemFromKeychain(for: key, ofType: ofType)
    }

    func getItem<T>(for key: String, and contactID: String, ofType: T) throws -> T? {
        return try getItemFromKeychain(for: key, and: contactID, ofType: ofType)
    }
}
