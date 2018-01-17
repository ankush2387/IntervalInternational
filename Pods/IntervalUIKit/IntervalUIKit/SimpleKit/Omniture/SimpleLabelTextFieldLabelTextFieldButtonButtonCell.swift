//
//  SimpleLabelTextFieldLabelTextFieldButtonButtonCell.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/6/18.
//

import Bond
import UIKit
import ReactiveKit

open class SimpleLabelTextFieldLabelTextFieldButtonButtonCell: SimpleTableViewCell {

    // MARK: - IBOutlets
    @IBOutlet fileprivate weak var label1: UILabel!
    @IBOutlet fileprivate weak var label2: UILabel!
    @IBOutlet fileprivate weak var button1: UIButton!
    @IBOutlet fileprivate weak var button2: UIButton!
    @IBOutlet fileprivate weak var textField1: UITextField!
    @IBOutlet fileprivate weak var textField2: UITextField!

    open var button1Pressed: (() -> Void)?
    open var button2Pressed: (() -> Void)?

    @IBAction func button1Tapped(_ sender: Any) {
        button1Pressed?()
    }

    @IBAction func button2Tapped(_ sender: Any) {
        button2Pressed?()
    }

    open weak var viewModel: SimpleLabelTextFieldLabelTextFieldButtonButtonCellViewModel? {
        didSet {
            if let viewModel = viewModel {

                textField1.placeholder = viewModel.placeholderText1
                textField2.placeholder = viewModel.placeholderText2

                viewModel.label1.bind(to: label1.reactive.text).dispose(in: onReuseBag)
                viewModel.label2.bind(to: label2.reactive.text).dispose(in: onReuseBag)
                viewModel.button1Title.bind(to: button1.reactive.title).dispose(in: onReuseBag)
                viewModel.button2Title.bind(to: button2.reactive.title).dispose(in: onReuseBag)

                viewModel.textFieldValue1
                    .bidirectionalBind(to: textField1.reactive.text)
                    .dispose(in: onReuseBag)

                viewModel.textFieldValue2
                    .bidirectionalBind(to: textField2.reactive.text)
                    .dispose(in: onReuseBag)

                if let keyboardType = viewModel.keyboardType1 {
                    textField1.keyboardType = keyboardType
                }

                if let keyboardType = viewModel.keyboardType2 {
                    textField2.keyboardType = keyboardType
                }

                viewModel.isEditing
                    .observeNext { [weak self] editing in
                        self?.textField1.isEnabled = editing
                        self?.textField1.textColor = !editing ? UIColor(red: 146.0/255.0, green: 146.0/255.0, blue: 146.0/255.0, alpha: 1) : IntervalThemeFactory.deviceTheme.textColorGray

                        self?.textField2.isEnabled = editing
                        self?.textField2.textColor = !editing ? UIColor(red: 146.0/255.0, green: 146.0/255.0, blue: 146.0/255.0, alpha: 1) : IntervalThemeFactory.deviceTheme.textColorGray
                    }
                    .dispose(in: onReuseBag)
            }
        }
    }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if isIPadTraitCollection() {
            textField1.font = IntervalThemeFactory.deviceTheme.font
            textField2.font = IntervalThemeFactory.deviceTheme.font
        }
    }
}
