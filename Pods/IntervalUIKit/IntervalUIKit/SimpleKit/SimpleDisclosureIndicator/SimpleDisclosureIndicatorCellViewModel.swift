//
//  SimpleDisclosureIndicatorCellViewModel.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/23/18.
//

import Bond
import UIKit

final public class SimpleDisclosureIndicatorCellViewModel {

    public var isEditing: Observable<Bool>
    public var cellHeight: Observable<CGFloat> = Observable(80)
    public var headerLabelText: Observable<NSAttributedString?>

    public init(headerLabelText: NSAttributedString? = nil, isEditing: Bool = true) {
        self.headerLabelText = Observable(headerLabelText)
        self.isEditing = Observable(isEditing)
    }
}

extension SimpleDisclosureIndicatorCellViewModel: SimpleCellViewModel {
    public func modelType() -> SimpleViewModelType {
        return .disclosureIndicatorCellViewModel
    }
}
