//
//  IUIKButton.swift
//  IntervalUIKit
//
//  Created by Ralph Fiol on 12/10/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import UIKit

@IBDesignable
open class IUIKButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable open var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
}
