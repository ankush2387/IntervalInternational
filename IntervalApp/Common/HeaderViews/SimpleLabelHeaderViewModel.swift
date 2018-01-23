//
//  SimpleLabelHeaderViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/11/18.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Bond
import Foundation

open class SimpleLabelHeaderViewModel {

    // MARK: - Properties

    open let headerTitle: Observable<String?>
    open let titleLabelFont: UIFont?

    public init(headerTitle: String?, titleLabelFont: UIFont?) {
        self.headerTitle = Observable(headerTitle)
        self.titleLabelFont = titleLabelFont
    }
}
