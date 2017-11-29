//
//  SimpleGenericTableViewCell.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/15/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public protocol SimpleGenericTableViewCell: SimpleGenericTableViewCellDataStore {
    var xib: UINib? { get }
    var identifier: String { get }
    func setUI(for index: Int)
}

public extension SimpleGenericTableViewCell {

    func readData(at index: Int) -> [String: Any] {
        return SimpleGenericTableViewCellData.sharedInstance.data[index]
    }

    func write(data: [String: Any]) {
        SimpleGenericTableViewCellData.sharedInstance.data.append(data)
    }

    func reset() {
        SimpleGenericTableViewCellData.sharedInstance.reset()
    }
}
