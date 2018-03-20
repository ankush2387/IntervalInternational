//
//  ChargeSummaryViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/26/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

final class ChargeSummaryViewModel {

    // MARK: - Public properties
    let totalTitle: String
    let headerTitle: String
    let descriptionTitle: String
    let currencyCode: String
    let countryCode: String?
    private (set) var charge: [(description: String, amount: Float)]
    
    lazy var attributedTotal: NSAttributedString? = { [unowned self] in
        let totalAmount = self.charge.map { $0.amount }.reduce(0, +)
        return totalAmount.currencyFormatter(for: self.currencyCode, for: self.countryCode, baseLineOffSet: 7)
    }()

    // MARK: - Lifecycle
    init(charge: [(description: String, amount: Float)],
         headerTitle: String,
         descriptionTitle: String,
         totalTitle: String,
         currencyCode: String,
         countryCode: String?) {

        self.charge = charge
        self.totalTitle = totalTitle
        self.headerTitle = headerTitle
        self.descriptionTitle = descriptionTitle
        self.currencyCode = currencyCode
        self.countryCode = countryCode
    }
}
