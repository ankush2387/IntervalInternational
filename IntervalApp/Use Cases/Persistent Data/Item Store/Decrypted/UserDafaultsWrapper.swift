//
//  UserDafaultsWrapper.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

struct UserDafaultsWrapper { }

extension UserDafaultsWrapper: DecryptedStore {
    
    func save<T: Hashable>(item: T, for key: String) throws {
        UserDefaults.standard.set(item, forKey: key)
    }
    
    func save<T: Hashable>(item: T, for key: String, and contactID: String) throws {
        UserDefaults.standard.set(item, forKey: key + contactID)
    }
    
    func getItem<T: Hashable>(for key: String, ofType: T) throws -> T? {
        return UserDefaults.standard.value(forKey: key) as? T
    }
    
    func getItem<T: Hashable>(for key: String, and contactID: String, ofType: T) throws -> T? {
        return UserDefaults.standard.value(forKey: key + contactID) as? T
    }
}
