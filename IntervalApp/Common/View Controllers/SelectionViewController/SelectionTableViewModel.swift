//
//  SelectionTableViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/24/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

final class SelectionTableViewModel {

    // MARK: - Private properties
    let cellTexts: [String?]

    // MARK: - Lifecycle
    init(cellTexts: [String?]) {
        self.cellTexts = cellTexts
    }
}
