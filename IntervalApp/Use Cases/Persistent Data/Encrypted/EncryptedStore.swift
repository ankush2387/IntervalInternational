//
//  EncryptedStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/13/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

protocol EncryptedStore {
    func save(item: String, for key: String) throws
    func getItem(for key: String) throws -> String?
}
