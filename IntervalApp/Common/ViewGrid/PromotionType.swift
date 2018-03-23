//
//  PromotionType.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 3/24/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit

enum PromotionType {
    case priority
    case escape
    case other(PromotionTypeUIConfiguration)

    var UIConfiguration: PromotionTypeUIConfiguration {
        switch self {
        case .priority:
            return PromotionTypeUIConfiguration(fontSize: 12,
                                                promotionText: "PRIORITY".localized(),
                                                promotionGridColor: #colorLiteral(red: 0.8170029521, green: 0.9014232755, blue: 0.9516292214, alpha: 1),
                                                promotionTextForegroundColor: .white,
                                                promotionLabelBackgroundColor: #colorLiteral(red: 0.0030285432, green: 0.4645938277, blue: 0.7470024228, alpha: 1))

        case .escape:
            return PromotionTypeUIConfiguration(fontSize: 12,
                                                promotionText: "ESCAPES".localized(),
                                                promotionGridColor: #colorLiteral(red: 0.8531374931, green: 0.9366180301, blue: 0.7453369498, alpha: 1),
                                                promotionTextForegroundColor: .white,
                                                promotionLabelBackgroundColor: #colorLiteral(red: 0.6660602689, green: 0.8570732474, blue: 0.4060024917, alpha: 1))

        case let .other(UIConfiguration):
            return UIConfiguration
        }
    }
}
