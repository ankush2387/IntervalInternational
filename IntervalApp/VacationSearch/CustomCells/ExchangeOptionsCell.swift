//
//  ExchangeOptionsCell.swift
//  IntervalApp
//
//  Created by Chetu on 15/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit

class ExchangeOptionsCell: UITableViewCell {
    
    //Outlets
    
    @IBOutlet weak var primaryPriceLabel: UILabel!
    @IBOutlet weak var fractionalPriceLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceCheckBox: IUIKCheckbox!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(selectedEplus: Bool) {
        
        if Constant.MyClassConstants.exchangeFees.count > 0 && Constant.MyClassConstants.exchangeFees[0].eplus != nil {
            if let eplus = Constant.MyClassConstants.exchangeFees[0].eplus?.price {
                primaryPriceLabel.text = String(Int(Float(eplus)))
                if(Constant.MyClassConstants.exchangeFees[0].eplus?.selected)! {
                    priceCheckBox.checked = true
                } else {
                    priceCheckBox.checked = false
                }
                let priceString = "\(eplus)"
                let priceArray = priceString.components(separatedBy: ".")
                if (priceArray.last!.count) > 1 {
                    fractionalPriceLabel.text = "\(priceArray.last!)"
                } else {
                    fractionalPriceLabel.text = "00"
                }
            }
            if let currencyCode = Constant.MyClassConstants.exchangeFees[0].currencyCode {
                 currencyLabel.text = Helper.currencyCodeToSymbol(code:currencyCode)
            }
           
        }
        
    }
}
