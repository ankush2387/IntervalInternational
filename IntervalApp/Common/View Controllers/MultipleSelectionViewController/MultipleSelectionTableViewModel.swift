//
//  MultipleSelectionTableViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 2/2/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

final class MultipleSelectionTableViewModel {
    
    // MARK: - Public properties
    let viewTitle: String?
    let dataSet: [MultipleSelectionCellModel]
    let previouslySelectedDataSet: [MultipleSelectionCellModel]

    // MARK: - Lifecycle
    init(viewTitle: String? = nil, dataSet: [MultipleSelectionCellModel], previouslySelectedDataSet: [MultipleSelectionCellModel] = []) {
        self.viewTitle = viewTitle
        self.dataSet = dataSet
        self.previouslySelectedDataSet = previouslySelectedDataSet
    }
}
