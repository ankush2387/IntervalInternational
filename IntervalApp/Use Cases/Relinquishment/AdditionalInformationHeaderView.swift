//
//  AdditionalInformationHeaderView.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/25/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit

final class AdditionalInformationHeaderView: UITableViewCell {

    // MARK: - Public properties
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    static var height: CGFloat {
        return 70
    }
    
    open class func headerView() -> UIView? {
        return Bundle(for: self).loadNibNamed(reuseIdentifier, owner: self)?.first as? UIView
    }
}
