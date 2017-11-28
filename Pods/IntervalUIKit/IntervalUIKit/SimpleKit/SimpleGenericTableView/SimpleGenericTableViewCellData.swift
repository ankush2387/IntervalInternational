//
//  SimpleGenericTableViewCellData.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/15/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

final class SimpleGenericTableViewCellData {

    // MARK: - Public properties
    static let sharedInstance = SimpleGenericTableViewCellData()
    var data: [[String: Any]] = []

    // MARK: - Lifecycle
    private init() { /* Private constructor - singleton pattern */ }

    // MARK: - Public functions
    func reset() {
        data.removeAll()
    }
}
