//
//  ProductCell.swift
//  IntervalApp
//
//  Created by CHETUMAC043 on 4/6/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import UIKit
import IntervalUIKit
import DarwinSDK

class ProductCell: UITableViewCell {
    @IBOutlet weak var lblExpire: UILabel!
    @IBOutlet weak var triangleView: TriangeView!
    
    @IBOutlet weak var innerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var lblExpireDate: UILabel!
    @IBOutlet weak var lblMembershipName: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpMemberProductData(membership: Membership, prod: Product) {
                if let productCode = prod.productCode {
                    productImageView.image = UIImage(named: productCode)
                }
                if prod.coreProduct {
                    //innerViewTopConstraint.constant = 3
                    productImageView.isHidden = false
                    triangleView.isHidden = true
                    innerView.backgroundColor = .white
                } else {
                   // innerViewTopConstraint.constant = 0
                    innerView.layer.cornerRadius = 2
        }
                if !prod.billingEntity.unwrappedString.contains("NON") {
                    lblExpireDate.text = nil
                    lblExpire.isHidden = true
                } else {
                    if let expDate = prod.expirationDate {
                        lblExpireDate.text = Helper.getWeekDay(dateString: expDate, getValue: Constant.MyClassConstants.month).appending(". ").appending(Helper.getWeekDay(dateString: expDate, getValue: Constant.MyClassConstants.date)).appending(", ").appending(Helper.getWeekDay(dateString: expDate, getValue: Constant.MyClassConstants.year))
                    }
                    lblExpireDate.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
                }
                
                lblMembershipName.text = Helper.getDisplayNameFor(membership: membership, product: membership.getProductWithHighestTier())
    }

}
