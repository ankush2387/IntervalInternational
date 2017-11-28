//
//  SimpleTableViewCell.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/06/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Bond
import ReactiveKit

// swiftlint:disable overridden_super_call
open class SimpleTableViewCell: UITableViewCell {

    // Since cells are re-usable we need to dispose of all SwiftBond event streams.  Use this bag.
    let onReuseBag = DisposeBag()

    // Sub-classes must call super to make sure this method is called
    open override func prepareForReuse() {
        onReuseBag.dispose()
    }
}
