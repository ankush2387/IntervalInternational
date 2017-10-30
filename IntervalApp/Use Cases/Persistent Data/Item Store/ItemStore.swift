//
//  ItemStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/13/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

protocol ItemStore {
    func save<T: Hashable>(item: T, for key: String) throws
    func save<T: Hashable>(item: T, for key: String, and contactID: String) throws
    func getItem<T: Hashable>(for key: String, ofType: T) throws -> T?
    func getItem<T: Hashable>(for key: String, and contactID: String, ofType: T) throws -> T?
}

protocol EncryptedStore: ItemStore { }
protocol DecryptedStore: ItemStore { }
