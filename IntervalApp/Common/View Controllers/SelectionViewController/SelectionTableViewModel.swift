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
    let cellTexts: [SelectionCell]
    let currentSelection: SelectionCell?

    // MARK: - Lifecycle
    init(cellTexts: [SelectionCell], currentSelection: SelectionCell?) {
        self.cellTexts = cellTexts
        self.currentSelection = currentSelection
    }
}
