//
//  Theme.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/6/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

// swiftlint:disable object_literal
public enum Theme {
    
    // MARK: - Currently only supporting iPad and iPhone
    case iPad
    case iPhone
    
    // MARK: - Currently iPhone and iPad have the same color scheme
    
    /// #1B1B1D
    public var textColorBlack: UIColor {
        return UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.0)
    }
    
    /// #99999D
    public var textColorGray: UIColor {
        return UIColor(red: 0.60, green: 0.60, blue: 0.62, alpha: 1.0)
    }
    
    /// #FF9500
    public var textColorLightOrange: UIColor {
        return UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1.0)
    }
    
    
    /// #F57F24
    public var textColorDarkOrange: UIColor {
        return UIColor(red: 0.96, green: 0.50, blue: 0.14, alpha: 1.0)
    }
    
    /// #0077BE
    public var intervalColorBlue: UIColor {
        return UIColor(red: 0.00, green: 0.47, blue: 0.75, alpha: 1.0)
    }
    
    /// #0077BE
    public var textColorBlue: UIColor {
        return intervalColorBlue
    }
    
    /// #00649D
    public var intervalColorDarkBlue: UIColor {
        return UIColor(red: 0.00, green: 0.39, blue: 0.62, alpha: 1.0)
    }
    
    /// #00649D
    public var textColorDarkBlue: UIColor {
        return intervalColorDarkBlue
    }
    
    /// #E9E9EB
    public var backgroundColorGray: UIColor {
        return UIColor(red: 0.91, green: 0.91, blue: 0.92, alpha: 1.0)
    }
    
    /// #70B909
    public var activeGreen: UIColor {
        return UIColor(red: 0.44, green: 0.73, blue: 0.04, alpha: 1.0)
    }
    
    public var font: UIFont {
        switch self {
        case .iPhone:
            return UIFont.systemFont(ofSize: 20)
            
        case .iPad:
            return UIFont.systemFont(ofSize: 25)
        }
    }
}
