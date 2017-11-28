//
//  Magazine.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 8/23/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Magazine {
    
    open var label : String?
    open var url : String?
    open var year : Int?
    open lazy var images = [Image]()
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.label = json["label"].string
        
        self.url = json["url"].string
        // Quick Fix: Some URLs contain http rather than https
        if let u = self.url {
            self.url = u.replacingOccurrences(of: "http://", with: "https://")
        }
        
        self.year = json["year"].intValue
        
        if json["images"].exists() {
            let imagesJsonArrary:[JSON] = json["images"].arrayValue
            self.images = imagesJsonArrary.map { Image(json:$0) }
        }
    }
    
}

