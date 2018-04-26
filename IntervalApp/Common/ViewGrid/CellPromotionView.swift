//
//  CellPromotionView.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 3/23/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

final class CellPromotionView: UIView {

    // MARK: - Private properties
    private var promotionType: PromotionType?

    // MARK: - Overrides
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        try? PromotionBackgroundView.drawPromotionUI(with: rect, resizing: .aspectFill, ofType: promotionType)
    }

    // MARK: - Public functions
    func setPromotionUI(for promotionType: PromotionType) {
        self.promotionType = promotionType
    }
}

// MARK: - SDK Convenience Method
extension CellPromotionView {
    func setPromotionUI(for bucket: AvailabilitySectionItemInventoryBucketUnit) {
        switch (bucket.priorityViewing, bucket.platinumEscape) {

        // Frank will clarify what should happen if we get both true
        // For now PriorityView UI will supercede escapeView UI
        case (true, true):
            setPromotionUI(for: .priority)

        // PriorityView
        case (true, false):
            setPromotionUI(for: .priority)

        // EscapeView
        case (false, true):
            setPromotionUI(for: .escape)

        // No promotion:
        case (false, false):
            isHidden = true
        }
    }
}
