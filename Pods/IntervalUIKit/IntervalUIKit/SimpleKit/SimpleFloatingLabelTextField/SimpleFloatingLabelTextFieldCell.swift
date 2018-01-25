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
    @IBOutlet weak var textField: SkyFloatingLabelTextField!

    // MARK: - Public properties
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

                viewModel.isEditing
                    .observeNext { [weak self] editing in
                        self?.textField.isEnabled = editing
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
        textField.tintColor = IntervalThemeFactory.deviceTheme.textColorGray
        textField.selectedTitleColor = IntervalThemeFactory.deviceTheme.textColorGray
        textField.layer.borderColor = IntervalThemeFactory.deviceTheme.backgroundColorGray.cgColor
    }
}
