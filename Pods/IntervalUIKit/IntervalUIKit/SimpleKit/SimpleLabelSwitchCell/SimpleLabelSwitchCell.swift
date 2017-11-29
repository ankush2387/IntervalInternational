//
//  SimpleLabelSwitchCell.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

open class SimpleLabelSwitchCell: SimpleTableViewCell {

    @IBOutlet private weak var mainLabel: UILabel!
	@IBOutlet private weak var secondaryLabel: UILabel!
    @IBOutlet private weak var enableSwitch: UISwitch!

    open weak var viewModel: SimpleLabelSwitchCellViewModel? {
        didSet {
            if let viewModel = self.viewModel {
				bind(to: viewModel)
			}
        }
    }

	private func bind(to viewModel: SimpleLabelSwitchCellViewModel) {
		viewModel.label
			.bind(to: mainLabel.reactive.text)
			.dispose(in: onReuseBag)

		viewModel.switchOn
			.bidirectionalBind(to: enableSwitch.reactive.isOn)
			.dispose(in: onReuseBag)

		viewModel.secondaryLabel
			.bind(to: secondaryLabel.reactive.text)
			.dispose(in: onReuseBag)

		viewModel.displaySecondaryLabel
			.map { !$0 }
			.bind(to: secondaryLabel.reactive.isHidden)
			.dispose(in: onReuseBag)
	}

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let font = IntervalThemeFactory.deviceTheme.font
        mainLabel.font = font
        mainLabel.textColor = IntervalThemeFactory.deviceTheme.primaryTextColor
        secondaryLabel.font = font
        secondaryLabel.textColor = IntervalThemeFactory.deviceTheme.secondaryTextColor
    }
}
