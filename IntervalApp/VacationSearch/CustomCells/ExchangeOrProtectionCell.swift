//
//  ExchangeOrProtectionCell.swift
//  IntervalApp
//
//  Created by Chetu on 16/11/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import UIKit

class ExchangeOrProtectionCell: UITableViewCell {
    
    //Outlets
    
    // TODO: - FIX (Aylwing note) This class is not correctly implemented
    // This class has several unused IBOutlets and was not designed with reusability in mind
    // Our cells are preety simple and only differ a little
    // We can have one cell that we pass a configuration flag into and it should know how to render
    // Will remove in the future.
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var additionalPriceLabel: UILabel!
    @IBOutlet weak var primaryPriceLabel: UILabel!
    @IBOutlet weak var fractionalPriceLabel: UILabel!
    @IBOutlet weak var additionalPrimaryPriceLabel: UILabel!
    @IBOutlet weak var additionalFractionalPriceLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var cellContentView: UIView!
    
    // MARK: - Private properties
    private var callBack: CallBack?
    
    // MARK: - Public functions
    func setCell(callBack: @escaping CallBack) {
        
        self.callBack = callBack
        let cellTap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        cellContentView.addGestureRecognizer(cellTap)
        let titleAttributes: [String : Any] = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
                                               NSForegroundColorAttributeName: #colorLiteral(red: 0.3423708081, green: 0.5919493437, blue: 0.7394192815, alpha: 1)]
        
        
        priceLabel.attributedText = NSAttributedString(string: priceLabel.text.unwrappedString, attributes: titleAttributes)
        priceView.subviews.forEach {
            if let label = $0 as? UILabel {
                label.textColor = #colorLiteral(red: 0.3423708081, green: 0.5919493437, blue: 0.7394192815, alpha: 1)
            }
        }
    }
    
    // MARK: - Private functions
    @objc private func cellTapped() {
        callBack?()
    }
}
