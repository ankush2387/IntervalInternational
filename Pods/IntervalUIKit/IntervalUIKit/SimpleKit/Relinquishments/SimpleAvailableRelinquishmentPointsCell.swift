//
//  SimpleAvailableRelinquishmentPointsCell.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/13/18.
//

import Bond
import UIKit
import ReactiveKit

final public class SimpleAvailableRelinquishmentPointsCell: SimpleTableViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var cigImageView: UIImageView!
    @IBOutlet private weak var availablePointsButton: UIButton!
    @IBOutlet private weak var goldPointsHeadingLabel: UILabel!
    @IBOutlet private weak var goldPointsSubHeadingLabel: UILabel!

    // MARK: - IBActions
    @IBAction private func actionButtonTapped(_ sender: Any) {
        actionButtonTapped?()
    }

    @IBAction private func availablePointsToolButtonTapped(_ sender: Any) {
        availablePointsToolButtonTapped?()
    }

    // MARK: - Public properties
    public var actionButtonTapped: (() -> Void)?
    public var availablePointsToolButtonTapped: (() -> Void)?

    open weak var viewModel: SimpleAvailableRelinquishmentPointsCellViewModel? {
        didSet {
            if let viewModel = viewModel {
                actionButton.isHidden = viewModel.actionButtonImage.value == nil
                viewModel.cigImage.bind(to: cigImageView.reactive.image).dispose(in: onReuseBag)
                viewModel.numberOfPoints.bind(to: pointsLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.actionButtonImage.flatMap { $0 }.bind(to: actionButton.reactive.image).dispose(in: onReuseBag)
                viewModel.availablePointsButtonText.bind(to: availablePointsButton.reactive.title).dispose(in: onReuseBag)
                viewModel.goldPointsHeadingLabelText.bind(to: goldPointsHeadingLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.goldPointsSubHeadingLabel.bind(to: goldPointsSubHeadingLabel.reactive.text).dispose(in: onReuseBag)
            }
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }

    // MARK: - Private functions
    private func setUI() {
        pointsLabel.textColor = IntervalThemeFactory.deviceTheme.textColorDarkOrange
        goldPointsSubHeadingLabel.textColor = IntervalThemeFactory.deviceTheme.textColorGray
        goldPointsHeadingLabel.textColor = IntervalThemeFactory.deviceTheme.textColorBlack
        availablePointsButton.layer.borderWidth = 2
        availablePointsButton.layer.cornerRadius = 4
        availablePointsButton.setTitleColor(IntervalThemeFactory.deviceTheme.textColorDarkBlue, for: .normal)
        availablePointsButton.layer.borderColor = IntervalThemeFactory.deviceTheme.backgroundColorGray.cgColor
    }
}
