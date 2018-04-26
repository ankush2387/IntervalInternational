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
 
    @IBOutlet weak var bottomHorizontalSeparator: UIView!
    func setUpMemberProductData(membership: Membership, prod: Product) {
                if let productCode = prod.productCode {
                    productImageView.image = UIImage(named: productCode)
                }
                if prod.coreProduct {
                    productImageView.isHidden = false
                    triangleView.isHidden = true
                    innerView.backgroundColor = .white
                } else {
                    innerView.layer.cornerRadius = 2
        }
        if prod.billingEntity.unwrappedString.uppercased() != BillingEntity.NonCorporate.rawValue {
                    lblExpireDate.text = nil
                    lblExpire.isHidden = true
                } else {
                    if let expDate = prod.expirationDate {
                        lblExpireDate.text = Helper.getWeekDay(dateString: expDate, getValue: Constant.MyClassConstants.month).appending("/").appending(Helper.getWeekDay(dateString: expDate, getValue: Constant.MyClassConstants.date)).appending("/").appending(Helper.getWeekDay(dateString: expDate, getValue: Constant.MyClassConstants.year))
                    }
                    lblExpireDate.font = UIFont(name: Constant.fontName.helveticaNeue, size: 15)
                }
                lblMembershipName.text = Helper.getProductNameFromProduct(product: prod)
    }

}
