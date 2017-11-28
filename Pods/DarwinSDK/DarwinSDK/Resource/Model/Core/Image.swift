//
//  Image.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/22/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Image {
    
    open var url :String?
    open var width : Int = 0
    open var height : Int = 0
    open var size :String?
    
    public init() {
    }
    
    public convenience init(url:String, size:ImageSize) {
        self.init()
        
        self.url = url
        self.size = size.rawValue
    }
    
    public convenience init(json:JSON) {
        self.init()
   
        self.url = json["url"].string
        // Quick Fix: Some URLs contain http rather than https
        if let u = self.url {
            self.url = u.replacingOccurrences(of: "http://", with: "https://")
        }
        
        self.size = json["type"].string
		
		if json["width"].exists() {
        	self.width = json["width"].intValue
		}
        
		if json["height"].exists() {
        	self.height = json["height"].intValue
		}
    }
    
}
