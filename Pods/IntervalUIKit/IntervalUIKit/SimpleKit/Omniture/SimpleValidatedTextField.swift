//
//  SimpleValidatedTextField.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/5/18.
//

import Bond
import UIKit
import ReactiveKit

open class SimpleValidatedTextField: UITextField {
    fileprivate let validTextFieldBorderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
    fileprivate let invalidTextFieldBorderColor = UIColor.red.cgColor
    fileprivate let defaultTextFieldBorderRadius: CGFloat = 3
    fileprivate let defaultTextFieldBorderWidth: CGFloat = 0.3
    let disposeBag = DisposeBag()

    open var validator: TextValidator? {
        didSet {
            disposeBag.dispose()
            if let validator = validator {
                reactive.text
                    .map{ validator.isValid($0 ?? "") }
                    .observeNext(with: updateDisplay)
                    .dispose(in: disposeBag)
            }
        }
    }

    func updateDisplay(_ valid: Bool) {
        clipsToBounds = true

        layer.masksToBounds = true
        layer.borderColor = valid ? validTextFieldBorderColor : invalidTextFieldBorderColor
        layer.borderWidth = valid ? defaultTextFieldBorderWidth : 1.5
        layer.cornerRadius = defaultTextFieldBorderRadius
    }
}
