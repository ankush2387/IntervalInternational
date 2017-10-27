//
//  ChargeSummaryTableViewCell.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/26/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

final class ChargeSummaryTableViewCell: UITableViewCell {

    // MARK: - Public properties
    static let identifier = "ChargeSummaryTableViewCell"
    static let nib = UINib(nibName: identifier, bundle: nil)

    // MARK: - IBOulets
    @IBOutlet private weak var chargeDescriptionLabel: UILabel!
    @IBOutlet private weak var chargeAmountLabel: UILabel!

    // MARK: - Public properties
    func setUI(with chargeDescription: String, and chargeAmount: Float) {
       
        if let attributedAmount = chargeAmount.currencyFormatter(for: "$") {
            chargeAmountLabel.attributedText = attributedAmount
            chargeDescriptionLabel.text = chargeDescription
        }
    }
}
