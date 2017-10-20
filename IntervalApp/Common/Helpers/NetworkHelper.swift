//
//  NetworkHelper.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/17/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

struct NetworkHelper {
    
    static func open(_ url: URL) {
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
