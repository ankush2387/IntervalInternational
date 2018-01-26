//
//  SimpleFloatingLabelTextFieldCell.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/23/18.
//

import Bond
import UIKit
import SkyFloatingLabelTextField

final public class SimpleFloatingLabelTextFieldCell: SimpleTableViewCell {

    // MARK: - IBOutlets
    @IBOutlet public weak var textField: SkyFloatingLabelTextField! {
        didSet {
            textField.delegate = self
        }
    }

    // MARK: - Public properties
    public var didSelectTextField: (() -> Void)?
    open weak var viewModel: SimpleFloatingLabelTextFieldCellViewModel? {
        didSet {
            if let viewModel = viewModel {
                setUI()

                viewModel.placeholderText.observeNext { [weak self] placeholder in
                    if let placeholder = placeholder {
                        self?.textField.placeholder = "    \(placeholder.uppercased())"
                        self?.textField.title = "     \(placeholder.uppercased())"
                    } else {
                        self?.textField.placeholder = nil
                        self?.textField.title = nil
                    }

                }.dispose(in: onReuseBag)
                
                
                
                viewModel.textFieldValue
                    .bidirectionalBind(to: textField.reactive.text)
                    .dispose(in: onReuseBag)

                if let keyboardType = viewModel.keyboardType {
                    textField.keyboardType = keyboardType
                }

                viewModel.isTappableTextField.observeNext { [weak self] enabled in
                    self?.textField.backgroundColor = enabled ? .clear : IntervalThemeFactory.deviceTheme.backgroundColorGray
                }.dispose(in: onReuseBag)
                
                viewModel.isEditing
                    .observeNext { [weak self] editing in
                        self?.textField.backgroundColor = editing ? .clear : IntervalThemeFactory.deviceTheme.backgroundColorGray
                        self?.textField.textColor = editing ? IntervalThemeFactory.deviceTheme.textColorBlack : IntervalThemeFactory.deviceTheme.textColorGray
                    }
                    .dispose(in: onReuseBag)
            }
        }
    }

    // MARK: - Private functions
    private func setUI() {

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always

        selectionStyle = .none
        textField.lineColor = .clear
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 3
        textField.selectedLineColor = .clear
        
        textField.tintColor = viewModel?.isTappableTextField.value == true || viewModel?.isEditing.value == false
            ? .clear : IntervalThemeFactory.deviceTheme.textColorGray
        textField.selectedTitleColor = IntervalThemeFactory.deviceTheme.textColorGray
        textField.layer.borderColor = IntervalThemeFactory.deviceTheme.backgroundColorGray.cgColor
        
        textField.rightView = viewModel?.showArrowIcon.value == true ? UIImageView(image: #imageLiteral(resourceName: "ForwardArrowIcon")) : nil
        textField.rightViewMode = viewModel?.showArrowIcon.value == true ? .always : .never
    }
}

extension SimpleFloatingLabelTextFieldCell: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if viewModel?.isEditing.value == false {
            textField.endEditing(true)
        }
        
        if viewModel?.isTappableTextField.value == true {
            didSelectTextField?()
            textField.resignFirstResponder()
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return viewModel?.isEditing.value == true
    }
}
