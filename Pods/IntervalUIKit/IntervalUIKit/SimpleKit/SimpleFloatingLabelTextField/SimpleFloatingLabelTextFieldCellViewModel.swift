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

    open var showArrowIcon: Observable<Bool>
    open var textFieldValue: Observable<String?>
    open var isTappableTextField: Observable<Bool>
    
    // The placeholder text assigned to the textfield
    open var placeholderText: Observable<String?>

    // To allow optional configuration of keyboard types.
    open var keyboardType: UIKeyboardType?

    public init(textFieldValue: String? = nil,
                placeholderText: String? = nil,
                keyboardType: UIKeyboardType? = nil,
                isSelectableTextField: Bool = false,
                showArrowIcon: Bool = false) {

        self.textFieldValue = Observable(textFieldValue)
        self.placeholderText = Observable(placeholderText)
        self.keyboardType = keyboardType
        self.isTappableTextField = Observable(isSelectableTextField)
        self.showArrowIcon = Observable(showArrowIcon)
    }
}

extension SimpleFloatingLabelTextFieldCellViewModel : SimpleCellViewModel {

    public func modelType() -> SimpleViewModelType {
        return .floatingLabelTextField
    }
}
