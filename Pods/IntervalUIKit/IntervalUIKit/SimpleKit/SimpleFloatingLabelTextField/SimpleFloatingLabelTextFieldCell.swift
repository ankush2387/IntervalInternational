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
    
    @IBOutlet private weak var tappableView: UIView!
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
                    guard let strongSelf = self else { return }
                    if let placeholder = placeholder {
                        strongSelf.textField.placeholder = "    \(placeholder.uppercased())"
                        strongSelf.textField.title = "     \(placeholder.uppercased())"
                    } else {
                        strongSelf.textField.placeholder = nil
                        strongSelf.textField.title = nil
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
                        guard let strongSelf = self else { return }
                        DispatchQueue.main.async {
                            let isActive = viewModel.isTappableTextField.value || editing
                            strongSelf.textField.backgroundColor = isActive ? .clear : IntervalThemeFactory.deviceTheme.backgroundColorGray
                            strongSelf.textField.tintColor = editing ? IntervalThemeFactory.deviceTheme.textColorGray : .clear
                            strongSelf.textField.textColor = editing ?
                                IntervalThemeFactory.deviceTheme.textColorBlack : IntervalThemeFactory.deviceTheme.textColorGray

                        }
                    }.dispose(in: onReuseBag)

                viewModel.isTappableTextField.observeNext { [weak self] enabled in
                    guard let strongSelf = self else { return }
                    strongSelf.tappableView.isHidden = !enabled
                    strongSelf.tappableView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                        action: #selector(strongSelf.didSelectCell)))
                    }.dispose(in: onReuseBag)
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

    @objc private func didSelectCell() {
        if viewModel?.isTappableTextField.value == true {
            didSelectTextField?()
        }
    }
}

extension SimpleFloatingLabelTextFieldCell: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Just in case user wants to copy paste content
        return viewModel?.isEditing.value == true
    }
}
