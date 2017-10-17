//
//  String+Localization.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

extension String {
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}
