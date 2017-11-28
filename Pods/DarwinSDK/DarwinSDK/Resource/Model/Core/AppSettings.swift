//
//  AppSettings.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 5/12/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AppSettings {

    open var currentVersion : String?
    open var currentVersionAlert : String?
    open var minimumSupportedVersion : String?
    open var minimumSupportedVersionAlert : String?
    
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.currentVersion = json["currentVersion"].string ?? ""
        self.currentVersionAlert = json["currentVersionAlert"].string ?? ""
        self.minimumSupportedVersion = json["minimumSupportedVersion"].string ?? ""
        self.minimumSupportedVersionAlert = json["minimumSupportedVersionAlert"].string ?? ""
    }
    
}
