//
//  TransactionDetailsTableViewCell.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 3/22/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class TransactionDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var travellingWithLabel: UILabel!
    @IBOutlet weak var cabinNumber: UILabel!
    @IBOutlet weak var cabinDetails: UILabel!
    @IBOutlet weak var transactionDate: UILabel!
    
    func setTransactionDetails(with transactionDetails: Cabin) {
        
        if let adults = transactionDetails.travelParty?.adults, let children = transactionDetails.travelParty?.children {
            travellingWithLabel.text = "\(adults) Adults"
            if children > 0 {
                travellingWithLabel.text = "\(adults) Adults, \(children) Children "
            }
            if let number = transactionDetails.number {
                cabinNumber.text = "\(number)"
            }
            if let details = transactionDetails.details {
                cabinDetails.text = details
            }
            if let date = transactionDetails.sailingDate {
                transactionDate.text = date
            }
        }
        
    }
}
