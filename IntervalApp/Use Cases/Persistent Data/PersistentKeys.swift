//
//  PersistentKeys.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

enum Persistent: String {

    case backgroundImageIndex
    case bundleIdentifier
    case userName
    case password
    case encryption
    case touchIDEnabled
    case newAppInstance
    case adobeMobileConfig
    case notificationTopic
    case appHasPreviousLogin
    case adobeMobileConfigCustomURL

    var key: String {
        
        switch self {
        case .bundleIdentifier:
            return Bundle.main.bundleIdentifier ?? "com.interval.touchToken"
            
        default:
            return self.rawValue
        }
    }
}
