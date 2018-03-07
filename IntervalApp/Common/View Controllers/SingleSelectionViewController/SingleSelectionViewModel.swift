//
//  SingleSelectionViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/24/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

final class SingleSelectionViewModel {

    // MARK: - Public properties
    let title: String?
    let cellUIType: SingleSelectionCellUIType
    let cellModels: [SingleSelectionCellModel]
    let currentSelectionCellModel: SingleSelectionCellModel?
    
    // MARK: - Lifecycle
    init(title: String? = nil,
         cellModels: [SingleSelectionCellModel],
         currentSelectionCellModel: SingleSelectionCellModel? = nil,
         cellUIType: SingleSelectionCellUIType = .checkMark) {
        self.title = title
        self.cellUIType = cellUIType
        self.cellModels = cellModels
        self.currentSelectionCellModel = currentSelectionCellModel
    }
}
