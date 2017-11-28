//
//  IUIKManager.swift
//  IntervalUIKit
//
//  Created by Ralph Fiol on 12/11/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import UIKit

open class IUIKitManager {
    
    open static func updateAppearance() {
        
        // Setup UINavigationBar defaults
        UINavigationBar.appearance().barTintColor = IUIKColorPalette.primary1.color
        UINavigationBar.appearance().backgroundColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        
    }
}
