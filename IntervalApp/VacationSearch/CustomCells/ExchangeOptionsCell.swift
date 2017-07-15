//
//  ExchangeOptionsCell.swift
//  IntervalApp
//
//  Created by Chetu on 15/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class ExchangeOptionsCell: UITableViewCell {
    
    //Outlets
    
    @IBOutlet weak var primaryPriceLabel: UILabel!
    @IBOutlet weak var fractionalPriceLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(selectedEplus: Bool) {
        
        if(Constant.MyClassConstants.exchangeFees[0].eplus != nil){
            primaryPriceLabel.text = String(Int(Float((Constant.MyClassConstants.exchangeFees[0].eplus?.price)!)))
            let priceString = "\(Constant.MyClassConstants.exchangeFees[0].eplus!.price)"
            let priceArray = priceString.components(separatedBy: ".")
            if((priceArray.last!.characters.count) > 1) {
                fractionalPriceLabel.text = "\(priceArray.last!)"
            }else{
                fractionalPriceLabel.text = "00"
            }
        }
        
    }


}
