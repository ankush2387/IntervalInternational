//
//  SimpleHandoutButtonCellViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import Bond

open class SimpleButtonCellViewModel {

    // From SimpleViewModelProtocol
    open var isEditing: Observable<Bool>
    open var buttonCellTitle: Observable<String?>

    public init(buttonCellTitle: String?, isEditing: Bool = true) {
        self.buttonCellTitle = Observable(buttonCellTitle)
        self.isEditing = Observable(isEditing)
    }
}

extension SimpleButtonCellViewModel: SimpleCellViewModel {
    public func modelType() -> SimpleViewModelType {
        return .buttonCell
    }
}
