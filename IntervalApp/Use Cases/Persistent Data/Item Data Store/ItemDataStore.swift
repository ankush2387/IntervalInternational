//
//  ItemDataStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/13/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

protocol ItemDataStore {
    func save<T>(item: T, for key: String) throws
    func save<T>(item: T, for key: String, and contactID: String) throws
    func getItem<T>(for key: String, ofType: T) throws -> T?
    func getItem<T>(for key: String, and contactID: String, ofType: T) throws -> T?
}

protocol MemoryItemDataStore: ItemDataStore { }
protocol EncryptedItemDataStore: ItemDataStore { }
protocol DecryptedItemDataStore: ItemDataStore { }
