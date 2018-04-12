//
//  AddButtonTableViewCell.swift
//  IntervalApp
//
//  Created by Kamalakanta Nayak on 03/04/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class AddButtonTableViewCell: UITableViewCell {
    
    static let identifier = "AddButtonTableViewCell"
    public var addButtonTapped: (() -> Void)?
    
    @IBAction private func addTapped(_sender: IUIKButton) {
        addButtonTapped?()
    }
}
