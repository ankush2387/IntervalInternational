//
//  SimpleFloatingLabelTextFieldCellViewModel.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/23/18.
//

import Bond
import Foundation

open class SimpleFloatingLabelTextFieldCellViewModel {

    open var isEditing = Observable(false)
    open var cellHeight: Observable<CGFloat> = Observable(70)

    open var textFieldValue: Observable<String?>

    // The placeholder text assigned to the textfield
    open var placeholderText: Observable<String?>

    // To allow optional configuration of keyboard types.
    open var keyboardType: UIKeyboardType?

    public init(textFieldValue: String? = nil, placeholderText: String? = nil, keyboardType: UIKeyboardType? = nil) {
        self.textFieldValue = Observable(textFieldValue)
        self.placeholderText = Observable(placeholderText)
        self.keyboardType = keyboardType
    }
}

extension SimpleFloatingLabelTextFieldCellViewModel : SimpleCellViewModel {

    public func modelType() -> SimpleViewModelType {
        return .floatingLabelTextField
    }
}
