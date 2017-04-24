//
//  FontConfiguration.swift
//  IntervalApp
//
//  Created by Chetuiwk1601 on 2/13/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
class FontConfig
{
    /*
     
     Code for font name
     
     */
    struct RobotoFont {
        static let RobotoBlack :String = "Roboto-Black"
        static let RobotoLight :String = "Roboto-Light"
        static let RobotoThin:String = "Roboto-Thin"
    }
    struct systemFont {
        static let helvetica:String = "Helvetica Neue"
    }
    /*
     Code for font sizes
     */
    struct iphone45fontSize {
        static let labelFontSize:CGFloat = 14
        static let headerLabelFontSize:CGFloat = 16
        static let sublabelFontSizeFor:CGFloat = 12
    }
    struct iphone6fontSize {
        static let labelFontSize:CGFloat = 18
        static let headerLabelFontSize:CGFloat = 20
        static let sublabelFontSizeFor:CGFloat = 16
    }
}
