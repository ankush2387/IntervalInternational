//
//  MemoryItemWrapper.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/2/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

final class MemoryItemWrapper {

    // MARK: - Public properties
    static let sharedInstance = MemoryItemWrapper()

    // MARK: - Private properties
    fileprivate var items: [String: Any] = [:]

    // MARK: - Lifecycle
    private init() { /* Private constructor for correct singleton pattern */ }
}

extension MemoryItemWrapper: MemoryItemDataStore {

    func save<T>(item: T, for key: String) throws {
        items[key] = item
    }

    func save<T>(item: T, for key: String, and contactID: String) throws {
        items[key + contactID] = item
    }

    func getItem<T>(for key: String, ofType: T) throws -> T? {
        return items[key] as? T
    }

    func getItem<T>(for key: String, and contactID: String, ofType: T) throws -> T? {
        return items[key + contactID] as? T
    }
}
