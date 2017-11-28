//
//  SimpleGenericTableViewCellDataStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/16/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public protocol SimpleGenericTableViewCellDataStore {
    func readData(at index: Int) -> [String: Any]
    func write(data: [String: Any])
    func reset()
}
