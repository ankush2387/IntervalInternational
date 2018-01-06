//
//  SimpleTextFieldCellViewModel.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/6/18.
//

import Bond
import Foundation

open class SimpleTextFieldCellViewModel {

    open var isEditing = Observable(true)

    // Contains the masked text for a textfield,
    // For example if the textfield contained the value "123-456-7890"
    // and the textFieldMasked the value to "XXX-XX-7890"
    // valueMasked would return "XXX-XX-7890"

    open var valueMasked: Observable<String?>

    // Contains the unmasked text for a textfield,
    // For example if the textfield contained the value "123-456-7890"
    // and was masked to "XXX-XX-7890"
    // valueMasked would have the original text without
    // the mask, "123-456-7890"

    open var valueUnmasked: Observable<String?> = Observable("")

    // The placeholder text assigned to the textfield

    open var placeholderText: String?

    // An object that must conform to SimpleMaskProtocol
    // handles masking and unmasking a textfield.

    open var textFieldMask: SimpleMaskProtocol?

    // An object that must conform to TextValidator protocol
    // handles validating.

    open var valueValidator: TextValidator?

    // To allow optional configuration of keyboard types.

    open var keyboardType: UIKeyboardType?

    public init(value: String?, placeholderText: String?, keyboardType: UIKeyboardType? = nil) {
        valueMasked = Observable(value)
        self.placeholderText = placeholderText
        self.keyboardType = keyboardType
    }
}

extension SimpleTextFieldCellViewModel : SimpleCellViewModel {

    public func modelType() -> SimpleViewModelType {
        return .textField
    }
}

