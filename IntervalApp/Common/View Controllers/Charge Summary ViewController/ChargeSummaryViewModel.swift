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
    let currency: String
    let totalTitle: String
    let headerTitle: String
    let descriptionTitle: String
    let currencySymbol: String
    private (set) var charge: [(description: String, amount: Float)]
    
    lazy var attributedTotal: NSAttributedString? = { 
        let totalAmount = self.charge.map { $0.amount }.reduce(0, +)
        return totalAmount.currencyFormatter(for: self.currencySymbol, baseLineOffSet: 7)
    }()

    // MARK: - Lifecycle
    init(charge: [(description: String, amount: Float)],
         headerTitle: String,
         descriptionTitle: String,
         currency: String,
         totalTitle: String,
         currencySymbol: String) {

        self.charge = charge
        self.currency = currency
        self.totalTitle = totalTitle
        self.headerTitle = headerTitle
        self.descriptionTitle = descriptionTitle
        self.currencySymbol = currencySymbol
    }
}
