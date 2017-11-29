//
//  SimpleLabelLabelCellViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Bond

open class SimpleLabelLabelCellViewModel {

    // From SimpleViewModelProtocol
    open var isEditing = Observable(false)

    open var label1: Observable<String?>
    open var label2: Observable<String?>

    public init(label1: String? = nil, label2: String? = nil) {
        self.label1 = Observable(label1)
        self.label2 = Observable(label2)
    }
}

extension SimpleLabelLabelCellViewModel: SimpleCellViewModel {
    public func modelType() -> SimpleViewModelType {
        return .labelLabel
    }
}
