//
//  AdditionalInformationHeaderView.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/25/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit

final class AdditionalInformationHeaderView: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var headerCallButton: UIButton!
    
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

    public var callButtonTapped: CallBack?
    
    func setCell(headerText: String?, hideCallButton: Bool = false) {
        headerLabel.text = headerText
        headerCallButton.isHidden = hideCallButton
    }

    // MARK: - IBActions
    @IBAction func didPressCallButton(_ sender: Any) {
        callButtonTapped?()
    }
}
