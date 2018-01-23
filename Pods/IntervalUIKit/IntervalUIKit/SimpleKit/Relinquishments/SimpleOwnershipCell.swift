//
//  SimpleOwnershipCell.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/14/18.
//

import UIKit

final public class SimpleOwnershipCell: SimpleTableViewCell {
    
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
    @IBOutlet private weak var exchangeNumberLabel: UILabel!
    
    // MARK: - Constraints
    @IBOutlet private weak var extraInformationLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var stateLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var weekLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var unitDetailsLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var unitCapacityLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var statusLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var expirationDateLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var flagsLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var relinquishmentPromotionBackgroundViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var exchangeNumberLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var actionButtonHeight: NSLayoutConstraint!
    @IBOutlet private weak var resortNameTopOffset: NSLayoutConstraint!
    @IBOutlet private weak var monthLabelHeight: NSLayoutConstraint!

    // MARK: - Public properties
    public var actionButtonTapped: (() -> Void)?
    
    public weak var viewModel: SimpleOwnershipCellViewModel? {
        didSet {
            if let viewModel = viewModel {
                setUI()
                viewModel.extraInformationLabelText.bind(to: extraInformationLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.ownershipStateLabelText.bind(to: stateLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.exchangeNumberLabelText.bind(to: exchangeNumberLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.monthLabelText.bind(to: monthLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.yearLabelText.bind(to: yearLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.weekLabelText.bind(to: weekLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.resortNameLabelText.bind(to: resortNameLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.unitDetailsLabelText.bind(to: unitDetailsLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.unitCapacityLabelText.bind(to: unitCapacityLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.statusLabelText.bind(to: statusLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.expirationDateLabelText.bind(to: expirationDateLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.flagsLabelText.bind(to: flagsLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.relinquishmentPromotionImage.bind(to: relinquishmentPromotionImageView.reactive.image).dispose(in: onReuseBag)
                viewModel.relinquishmentPromotionLabelText.bind(to: relinquishmentPromotionLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.actionButton.flatMap { $0 }.bind(to: actionButton.reactive.image).dispose(in: onReuseBag)
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBAction func actionButtonTapped(_ sender: Any) {
        actionButtonTapped?()
    }
    
    // MARK: - Private functions
    private func setUI() {

        selectionStyle = .none
        stateLabel.textColor = IntervalThemeFactory.deviceTheme.activeGreen
        yearLabel.textColor = IntervalThemeFactory.deviceTheme.textColorDarkOrange
        actionButton.tintColor = IntervalThemeFactory.deviceTheme.textColorDarkOrange
        relinquishmentPromotionLabel.textColor = IntervalThemeFactory.deviceTheme.textColorBlue
        
        stateLabel.layer.borderWidth = 2
        stateLabel.layer.cornerRadius = 4
        stateLabel.layer.borderColor = IntervalThemeFactory.deviceTheme.backgroundColorGray.cgColor
        
        [extraInformationLabel, monthLabel, weekLabel, unitCapacityLabel, exchangeNumberLabel].forEach {
            $0?.textColor = IntervalThemeFactory.deviceTheme.textColorGray
        }
        
        [resortNameLabel, unitDetailsLabel].forEach {
            $0?.textColor = IntervalThemeFactory.deviceTheme.textColorBlack
        }
        
        [statusLabel, expirationDateLabel, flagsLabel].forEach {
            $0?.textColor = IntervalThemeFactory.deviceTheme.textColorLightOrange
        }
        
        setConstraints()
    }
    
    private func setConstraints() {

        let secondaryLableValues = [viewModel?.unitDetailsLabelText.value,
         viewModel?.unitCapacityLabelText.value,
         viewModel?.statusLabelText.value,
         viewModel?.expirationDateLabelText.value,
         viewModel?.flagsLabelText.value].flatMap { $0 }

        resortNameTopOffset.constant = secondaryLableValues.count == 0 ? 40 : 5
        extraInformationLabelHeight.constant = viewModel?.extraInformationLabelText.value == nil ? 0 : 20
        stateLabelHeight.constant = viewModel?.ownershipStateLabelText.value == nil ? 0 : 40
        exchangeNumberLabelHeight.constant = viewModel?.exchangeNumberLabelText.value == nil ? 0 : 30
        weekLabelHeight.constant = viewModel?.weekLabelText.value == nil ? 0 : 20
        unitDetailsLabelHeight.constant = viewModel?.unitDetailsLabelText.value == nil ? 0 : 20
        unitCapacityLabelHeight.constant = viewModel?.unitCapacityLabelText.value == nil ? 0 : 20
        statusLabelHeight.constant = viewModel?.statusLabelText.value == nil ? 0 : 20
        expirationDateLabelHeight.constant = viewModel?.expirationDateLabelText.value == nil ? 0 : 20
        flagsLabelHeight.constant = viewModel?.flagsLabelText.value == nil ? 0 : 20
        relinquishmentPromotionBackgroundViewHeight.constant = viewModel?.relinquishmentPromotionLabelText.value == nil ? 0 : 25
    }
}

