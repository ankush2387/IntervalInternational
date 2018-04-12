//
//  SelectPaymentMethodCell.swift
//  IntervalApp
//
//  Created by Chetu on 17/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class SelectPaymentMethodCell: UITableViewCell {
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardLastFourDigitNumber: UILabel!
    @IBOutlet weak var expireDate: UILabel!
    @IBOutlet weak var cardHolderName: UILabel!
    @IBOutlet weak var cardSelectionCheckBox: IUIKCheckbox!
    @IBOutlet weak var backgroundCellView: UIView!

}
