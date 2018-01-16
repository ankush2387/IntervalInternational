//
//  SimpleLabelHeaderView.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/11/18.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Bond
import UIKit

open class SimpleLabelHeaderView: SimpleHeaderView {

    // MARK: - Outlet(s)

    @IBOutlet fileprivate weak var containerView: UIView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!

    // MARK: - Properties

    open weak var viewModel: SimpleLabelHeaderViewModel? {
        didSet {
            if let viewModel = viewModel {
                viewModel.headerTitle.bind(to: titleLabel.reactive.text).dispose(in: onReuseBag)
            }
        }
    }

    // MARK: - Override Method(s)

    override func configureUI() {
        if let headerType = headerType {
            containerView.backgroundColor = headerType.backgroundColorForHeaderViewType()
            titleLabel.textColor = headerType.titleColorForHeaderViewType()
            if let titleLabelFont = viewModel?.titleLabelFont {
                titleLabel.font = titleLabelFont
            } else {
                titleLabel.font = headerType.font()
            }
        }
    }

    override open class func estimatedHeight() -> CGFloat {
        return 30
    }
}
