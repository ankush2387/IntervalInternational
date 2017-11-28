//
//  UIColorExtensions.swift
//  IntervalUIKit
//
//  Created by Ralph Fiol on 12/10/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import UIKit

//
// Define ENUM for the Interval Color Palette
// This is maintained by the web design team.
//
public enum IUIKColorPalette : UInt {
    case primary1   = 0x0077be
    case primary2   = 0x00b2dd
    case primary3   = 0xf57f26
    case primary4   = 0xeab710

    case secondary1 = 0xacc42a
    case secondary2 = 0xfdb813

    case tertiary1  = 0xf1f5f8
    case tertiary2  = 0xefefeb
    case tertiary3  = 0x8e8d8c
    case tertiary4  = 0xe6e6e7
    case tertiary5  = 0xe2ef9d
    case tertiary6  = 0x025c92
    
    case primaryB  = 0x00649d
    case secondaryA  = 0xf57f24
    case secondaryB  = 0xff9500
    case primaryText  = 0x1b1b1d
    case secondaryText  = 0x99999d
    case border  = 0xa7a7aa
    case altState  = 0xc9c9ce
    case searchBackdrop  = 0xe9e9eb
    case titleBackdrop  = 0xefeff6
    case contentBackground  = 0xffffff
    case approve  = 0xa9da63
    case active  = 0x70b909
    case announcement  = 0xfbf19c
    case annText  = 0xc09e54
    case alert  = 0xe06054

    
    public var color : UIColor {
        return UIColor(rgb: self.rawValue)
    }
}

//
// Add extensions to UIColor to support Web-like CSS (RGB) values
// Include convenience methods for the Interval Color Palette
//
public extension UIColor {
    
    convenience public init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    public static func color(_ colorPalette:IUIKColorPalette) -> UIColor {
        return colorPalette.color
    }
}
