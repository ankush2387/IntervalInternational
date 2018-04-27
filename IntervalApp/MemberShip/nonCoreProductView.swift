//
//  nonCoreProductView.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 8/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class nonCoreProductView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var externalView: UIView!
    @IBOutlet weak var triangleView: TriangeView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var nameLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var expiresLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var expireLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeView()
    }
    
    func initializeView() {
        Bundle.main.loadNibNamed("nonCoreProduct", owner: self, options: [:])
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
