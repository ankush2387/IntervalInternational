//
//  SimpleHeaderView.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/11/18.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Bond
import ReactiveKit
import Foundation
import IntervalUIKit

public enum SimpleHeaderViewType {
    case sectionHeaderGray
    case sectionHeaderWhite

    public func titleColorForHeaderViewType() -> UIColor {
        switch self {
        case .sectionHeaderGray: return IntervalThemeFactory.deviceTheme.textColorGray
        case .sectionHeaderWhite: return IntervalThemeFactory.deviceTheme.textColorBlack
        }
    }

    public func backgroundColorForHeaderViewType() -> UIColor {
        switch self {
        case .sectionHeaderGray: return IntervalThemeFactory.deviceTheme.backgroundColorGray
        case .sectionHeaderWhite: return .white
        }
    }
}

open class SimpleHeaderView: UITableViewHeaderFooterView {

    // MARK: - Properties

    let onReuseBag = DisposeBag()

    open var headerType: SimpleHeaderViewType? {
        didSet {
            configureUI()
        }
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        onReuseBag.dispose()
    }

    required public init?(coder aDecoder: NSCoder) {
        headerType = .sectionHeaderWhite
        super.init(coder: aDecoder)
    }

    func configureUI() {
        // Override in subclasses.
    }

    open class func reuseIdentifier() -> String {
        return String(describing: self)
    }

    open class func estimatedHeight() -> CGFloat {
        return 75
    }

    open class func height() -> CGFloat {
        return UITableViewAutomaticDimension
    }

    open class func nib() -> UINib? {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: SimpleHeaderView.self))
    }
}
