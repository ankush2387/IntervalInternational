//
//  SimpleHandoutButtonCell.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import Bond

// swiftlint:disable private_outlet
open class SimpleButtonCell: SimpleTableViewCell {

    @IBOutlet open weak var buttonCell: UIButton!

    @IBAction func buttonTapped(_ sender: AnyObject) {
        buttonPressed?()
    }

    open var buttonPressed: (() -> Void)?

    open weak var viewModel: SimpleButtonCellViewModel? {
        didSet {
            buttonCell.titleLabel?.font = IntervalThemeFactory.deviceTheme.font
            if let viewModel = self.viewModel {
                viewModel.buttonCellTitle.bind(to: buttonCell.reactive.title).dispose(in: onReuseBag)

                viewModel.isEditing
                    .observeNext { [ weak self] enabled in self?.buttonCell.isEnabled = enabled }
                    .dispose(in: onReuseBag)
            }
        }
    }
}
