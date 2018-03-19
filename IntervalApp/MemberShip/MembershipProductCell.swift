//
//  MembershipProductCell.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 8/3/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class MembershipProductCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var triangleView: TriangeView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var externalContainerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(product: Product) {
        var dateString = ""
        if let expDate = product.expirationDate {
            dateString = expDate.stringWithShortFormatForJSON()
        }
        
        productNameLabel.text = product.productName
        expirationDateLabel.text = dateString
        
        if product.highestTier == false {
            if let imageName = product.productCode {
                productImageView.image = UIImage(named: imageName)
            }
        }
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
