//
//  Float+CurrencyFormatter.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/27/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

extension Float {
    
    /// Returns a NSAttributedString string with specified currency symbol.
    /// Allows for caller to specify the baselineOffSet for currency and decimal numbers.
    /// Returns nil in case of a failure.
    
    func currencyFormatter(for currency: String = "", baseLineOffSet: Int = 5) -> NSAttributedString? {
        let amount = String(format: "%.2f", self)
        let attributes: [String: Any] = [NSFontAttributeName: UIFont.systemFont(ofSize: 9), NSBaselineOffsetAttributeName: baseLineOffSet]
        let attributedTextWithAttributedCurrencySign = NSMutableAttributedString(string: currency, attributes: attributes)
        let attributedAmount = NSMutableAttributedString(string: amount)
        guard let range = amount.NSRangeFor(.after, character: ".") else { return nil }
        attributedAmount.addAttributes(attributes, range: range)
        attributedTextWithAttributedCurrencySign.append(attributedAmount)
        return attributedTextWithAttributedCurrencySign
    }
}
