//
//  SimpleLabelTextLabelTextCellViewModel.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/5/18.
//

import Bond
import ReactiveKit
import UIKit

class SimpleTextFieldCell: SimpleTableViewCell {
    
    @IBOutlet fileprivate weak var textField: SimpleMaskedTextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    open weak var viewModel: SimpleTextFieldCellViewModel? {
        didSet {
            if let viewModel = viewModel {
                
                textField.placeholder = viewModel.placeholderText
                
                viewModel.valueMasked
                    .bidirectionalBind(to: textField.reactive.text)
                    .dispose(in: onReuseBag)
                
                if let keyboardType = viewModel.keyboardType {
                    textField.keyboardType = keyboardType
                }
                
                // Masking...
                
                if let textFieldMask = viewModel.textFieldMask {
                    textField.textFieldMask = textFieldMask
                    
                    textField.maskText(viewModel.valueMasked.value ?? "")
                    
                    textFieldMask.unmaskedText
                        .observeNext(with: { [weak self] text in
                            self?.viewModel?.valueUnmasked.value = textFieldMask.textWithoutFormatting(string: text ?? "")
                        })
                        .dispose(in: onReuseBag)
                }
                
                // Validation...
                
                if let validator = viewModel.valueValidator {
                    textField.validator = validator
                }
                
                viewModel.isEditing
                    .observeNext { [weak self] editing in
                        self?.textField.isEnabled = editing
                        self?.textField.textColor = !editing ? UIColor(red: 146.0/255.0, green: 146.0/255.0, blue: 146.0/255.0, alpha: 1) : IntervalThemeFactory.deviceTheme.textColorGray
                    }
                    .dispose(in: onReuseBag)
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if isIPadTraitCollection() {
            textField.font = UIFont.systemFont(ofSize: 25)
        }
    }
}

extension SimpleTextFieldCell: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldMask = viewModel?.textFieldMask else {
            return true
        }
        
        guard let entireString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else {
            return true
        }
        
        return entireString.count <= textFieldMask.formattingPattern.count
    }
}

