//
//  DarwinAccessToken.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 12/8/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class DarwinAccessToken {
    
    open var token : String?
    open var scope : String?
    open var tokenType : String?
    open var expiresIn : Int64?
    
    public init() {
    }
    
    public init(json:JSON) {
        self.token = json["access_token"].string
        self.scope = json["scope"].string
        self.tokenType = json["token_type"].string
        self.expiresIn = json["expires_in"].int64Value
    }
    
}
