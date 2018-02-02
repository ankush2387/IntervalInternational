//
//  MultipleSelectionTableViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 2/2/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

final class MultipleSelectionTableViewModel<T> where T: MultipleSelectionElement {
    
    // MARK: - Public properties
    let viewTitle: String?
    let dataSet: [T]
    let previouslySelectedDataSet: [MultipleSelectionElement]

    // MARK: - Lifecycle
    init(viewTitle: String? = nil, dataSet: [T], previouslySelectedDataSet: [MultipleSelectionElement] = []) {
        self.viewTitle = viewTitle
        self.dataSet = dataSet
        self.previouslySelectedDataSet = previouslySelectedDataSet
    }
}
