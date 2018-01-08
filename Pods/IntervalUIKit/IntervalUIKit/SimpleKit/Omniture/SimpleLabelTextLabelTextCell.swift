//
//  SimpleLabelTextLabelTextCell.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/5/18.
//

import Foundation

open class SimpleLabelTextLabelTextCell : SimpleTableViewCell {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var valueTextField1: UITextField!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var valueTextField2: UITextField!

    open weak var viewModel: SimpleLabelTextLabelTextCellViewModel? {
        didSet {
            if let viewModel = self.viewModel {
                // Binding
                viewModel.label1.bind(to: label1.reactive.text).dispose(in: onReuseBag)
                // Handles user hitting return or using auto-correction which bidirectional doesn't handle...
                valueTextField1.reactive.controlEvents(.editingDidEnd)
                    .observeNext {[weak self] _ in viewModel.value1.value = self?.valueTextField1.text}
                    .dispose(in: onReuseBag)
                viewModel.value1.bidirectionalBind(to: valueTextField1.reactive.text).dispose(in: onReuseBag)
                viewModel.label2.bind(to: label2.reactive.text).dispose(in: onReuseBag)
                // Handles user hitting return or using auto-correction which bidirectional doesn't handle...
                valueTextField2.reactive.controlEvents(.editingDidEnd)
                    .observeNext {[weak self] _ in viewModel.value2.value = self?.valueTextField2.text}
                    .dispose(in: onReuseBag)
                viewModel.value2.bidirectionalBind(to: valueTextField2.reactive.text).dispose(in: onReuseBag)

                viewModel.isEditing
                    .observeNext { [weak self] editing in
                        self?.valueTextField1.borderStyle = editing ? .roundedRect : .none
                        self?.valueTextField1.isEnabled = editing
                        self?.valueTextField2.borderStyle = editing ? .roundedRect : .none
                        self?.valueTextField2.isEnabled = editing
                    }
                    .dispose(in: onReuseBag)
            }
        }
    }

    open override func awakeFromNib() {
        // Had to add set these here because it wouldn't work via the IB. Must be an Xcode 8 bug.
        valueTextField1.delegate = self
        valueTextField2.delegate = self
    }
}

extension SimpleLabelTextLabelTextCell : UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let viewModel = viewModel, let validator = textField == valueTextField1 ? viewModel.value1LengthValidator : viewModel.value2LengthValidator  else {
            return true
        }
        guard let entireString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else {
            return true
        }
        return validator.isValid(entireString)
    }
}
