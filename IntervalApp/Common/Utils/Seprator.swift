//
//  Seprator.swift
//  IntervalApp
//
//  Created by ChetuMac-007 on 01/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

class Seprator: UIView {

    init( x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat ) {
         super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
         self.backgroundColor = .lightGray
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
