//
//  OwnershipTableViewCell.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/14/18.
//

import UIKit

final public class OwnershipTableViewCell: SimpleTableViewCell {

    // MARK: - IBOulets
    @IBOutlet private weak var extraInformationLabel: UILabel!
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var weekLabel: UILabel!
    @IBOutlet private weak var resortNameLabel: UILabel!
    @IBOutlet private weak var unitDetailsLabel: UILabel!
    @IBOutlet private weak var unitCapacityLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var expirationDateLabel: UILabel!
    @IBOutlet private weak var flagsLabel: UILabel!
    @IBOutlet private weak var relinquishmentPromotionImageView: UIImageView!
    @IBOutlet private weak var relinquishmentPromotionLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!

    // MARK: - Constraints
    @IBOutlet private weak var extraInformationLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var stateLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var weekLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var unitDetailsLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var unitCapacityLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var statusLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var expirationDateLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var flagsLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var relinquishmentPromotionBackgroundViewHeight: NSLayoutConstraint!

    // MARK: - Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }

    public weak var viewModel: OwnershipTableViewCellViewModel? {
        didSet {

        }
    }

    // MARK: - Private functions
    private func setUI() {

        stateLabel.textColor = IntervalThemeFactory.deviceTheme.activeGreen
        yearLabel.textColor = IntervalThemeFactory.deviceTheme.textColorDarkOrange
        relinquishmentPromotionLabel.textColor = IntervalThemeFactory.deviceTheme.textColorBlue

        stateLabel.layer.borderWidth = 2
        stateLabel.layer.cornerRadius = 4
        stateLabel.layer.borderColor = IntervalThemeFactory.deviceTheme.backgroundColorGray.cgColor

        [extraInformationLabel, monthLabel, weekLabel, unitCapacityLabel].forEach {
            $0?.textColor = IntervalThemeFactory.deviceTheme.textColorGray
        }

        [resortNameLabel, unitDetailsLabel].forEach {
            $0?.textColor = IntervalThemeFactory.deviceTheme.textColorBlack
        }

        [statusLabel, expirationDateLabel, flagsLabel].forEach {
            $0?.textColor = IntervalThemeFactory.deviceTheme.textColorLightOrange
        }
    }
}
