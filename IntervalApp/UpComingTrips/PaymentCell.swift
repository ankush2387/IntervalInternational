//
//  PaymentCell.swift
//  IntervalApp
//
//  Created by Chetu on 03/03/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class PaymentCell: UITableViewCell {
    
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak var balanceDueLabel: UILabel!
    @IBOutlet weak var balanceDueDateLabel: UILabel!
    
    func setPayment(with paymentInfo: CruiseSupplementalPayment) {
        if let depositAmount = paymentInfo.depositAmount,
            let balanceDueAmount = paymentInfo.balanceDueAmount,
            let balanceDueDate = paymentInfo.balanceDueDate,
            let currencyCode = depositAmount.currencyCode {
            depositLabel.text = "\(currencyCode) \(depositAmount.amount)"
            balanceDueLabel.text = "\(currencyCode) \(balanceDueAmount.amount)"
            balanceDueDateLabel.text = balanceDueDate
        }
    }
    
}
