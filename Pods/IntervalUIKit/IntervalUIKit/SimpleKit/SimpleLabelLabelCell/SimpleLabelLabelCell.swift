//
//  SimpleLabelLabelCell.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

// swiftlint:disable private_outlet
open class SimpleLabelLabelCell: SimpleTableViewCell {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!

    open weak var viewModel: SimpleLabelLabelCellViewModel? {
        didSet {
            if let viewModel = self.viewModel {
                // Binding
                viewModel.label1
                    .bind(to: label1.reactive.text)
                    .dispose(in: onReuseBag)

                viewModel.label2
                    .bind(to: label2.reactive.text)
                    .dispose(in: onReuseBag)
            }
        }
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let font = IntervalThemeFactory.deviceTheme.font
        label1.font = font
        label1.textColor = IntervalThemeFactory.deviceTheme.primaryTextColor
        label2.font = font
        label2.textColor = (label1.text ?? "").isEmpty ? IntervalThemeFactory.deviceTheme.primaryTextColor : IntervalThemeFactory.deviceTheme.secondaryTextColor
    }
}
