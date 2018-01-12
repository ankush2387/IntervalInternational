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
    public var textColorBlack: UIColor {
        return UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.0)
    }
    
    public var textColorGray: UIColor {
        return UIColor(red: 0.60, green: 0.60, blue: 0.62, alpha: 1.0)
    }
    
    public var backgroundColorGray: UIColor {
        return UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
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

