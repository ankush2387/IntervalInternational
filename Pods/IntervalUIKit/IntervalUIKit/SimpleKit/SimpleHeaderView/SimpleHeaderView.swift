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

    public func font() -> UIFont {
        switch self {
        case .sectionHeaderGray: return UIFont.systemFont(ofSize: 15)
        case .sectionHeaderWhite: return UIFont.systemFont(ofSize: 15)
        }
    }
}

open class SimpleHeaderView: UITableViewCell {

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
        return 40
    }

    open class func height() -> CGFloat {
        return UITableViewAutomaticDimension
    }

    open class func headerView() -> UIView? {
        return Bundle(for: self).loadNibNamed(reuseIdentifier(), owner: self)?.first as? UIView
    }
}
