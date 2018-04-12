//
//  AddButtonTableViewCell.swift
//  IntervalApp
//
//  Created by Abhilasha Thapliyal on 03/04/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class AddButtonTableViewCell: UITableViewCell {
    
    static let identifier = "AddButtonTableViewCell"
    public var addButtonTapped: CallBack?
    
    @IBAction private func addTapped(_sender: IUIKButton) {
        addButtonTapped?()
    }
}
