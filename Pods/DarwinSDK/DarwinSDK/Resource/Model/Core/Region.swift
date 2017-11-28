//
//  Region.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 6/3/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Region {
    
    open var regionCode : Int = 0
    open var regionName : String?
    open lazy var regions = [Region]()
    open lazy var areas = [Area]()
    
    public init() {
    }
    
    public convenience init(regionCode:Int) {
        self.init()
        self.regionCode = regionCode
    }
    
    public convenience init(regionCode:Int, regionName:String) {
        self.init()
        self.regionCode = regionCode
        self.regionName = regionName
    }
    
    public convenience init(json:JSON){
        self.init()
        
        if let value = json["regionCode"].int {
            self.regionCode = value
        } else if let value = json["code"].int {
            self.regionCode = value
        } else if let value = json["code"].string {
            self.regionCode = Int(value)!
        }
        
        if let value = json["regionName"].string {
            self.regionName = value
        } else if let value = json["name"].string {
            self.regionName = value
        }
        
        if json["areas"].exists() {
            let areasArrary:[JSON] = json["areas"].arrayValue
            self.areas = areasArrary.map { Area(json:$0) }
        }
    }
        
}
