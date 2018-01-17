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
    
    public weak var viewModel: SimpleOwnershipCellViewModel? {
        didSet {
            if let viewModel = viewModel {
                viewModel.extraInformationLabelText.bind(to: extraInformationLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.ownershipStateLabelText.bind(to: stateLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.monthLabelText.bind(to: monthLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.yearLabelText.bind(to: yearLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.weekLabelText.bind(to: weekLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.resortNameLabelText.bind(to: resortNameLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.unitDetailsLabelText.bind(to: unitDetailsLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.unitCapacityLabelText.bind(to: unitCapacityLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.statusLabelText.bind(to: stateLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.expirationDateLabelText.bind(to: expirationDateLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.flagsLabelText.bind(to: flagsLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.relinquishmentPromotionImage.bind(to: relinquishmentPromotionImageView.reactive.image).dispose(in: onReuseBag)
                viewModel.relinquishmentPromotionLabelText.bind(to: relinquishmentPromotionLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.actionButton.flatMap { $0 }.bind(to: actionButton.reactive.image).dispose(in: onReuseBag)
            }
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
        
        if case .none = viewModel?.extraInformationLabelText.value {
            extraInformationLabelHeight.constant = 0
        }
        
        if case .none = viewModel?.statusLabelText.value {
            stateLabelHeight.constant = 0
        }
        
        if case .none = viewModel?.weekLabelText.value {
            weekLabelHeight.constant = 0
        }
        
        if case .none = viewModel?.unitDetailsLabelText.value {
            unitDetailsLabelHeight.constant = 0
        }
        
        if case .none = viewModel?.unitCapacityLabelText.value {
            unitCapacityLabelHeight.constant = 0
        }
        
        if case .none = viewModel?.statusLabelText.value {
            statusLabelHeight.constant = 0
        }
        
        if case .none = viewModel?.expirationDateLabelText.value {
            expirationDateLabelHeight.constant = 0
        }
        
        if case .none = viewModel?.flagsLabelText.value {
            flagsLabelHeight.constant = 0
        }
        
        if case .none = viewModel?.relinquishmentPromotionLabelText.value {
            relinquishmentPromotionBackgroundViewHeight.constant = 0
        }
    }
}

