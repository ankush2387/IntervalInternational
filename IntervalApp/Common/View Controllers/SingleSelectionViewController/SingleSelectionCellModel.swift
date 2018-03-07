//
//  SingleSelectionCellModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 2/13/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

struct SingleSelectionCellModel {

    // MARK: - Public properties
    let cellTitle: String
    let cellSubtitle: String?

    // MARK: - Lifecycle
    init(cellTitle: String, cellSubtitle: String? = nil) {
        self.cellTitle = cellTitle
        self.cellSubtitle = cellSubtitle
    }
}
