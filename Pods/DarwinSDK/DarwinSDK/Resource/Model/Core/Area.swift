//
//  Area.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/21/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Area {
    
    open var areaCode : Int = 0
    open var areaName : String?
    open var description : String?
    open var coordinates : Coordinates?
    open lazy var images = [Image]()
    open lazy var bannerImages = [Image]()
    open lazy var magazines = [Magazine]()

    public init() {
    }
    
    public convenience init(areaCode: Int) {
        self.init()
        
        self.areaCode = areaCode
    }
    
    public convenience init(areaCode: Int, areaName: String) {
        self.init()
        
        self.areaCode = areaCode
        self.areaName = areaName
    }
    
    public convenience init(json:JSON){
        self.init()
        
        if let value = json["areaCode"].int {
            self.areaCode = value
        } else if let value = json["code"].int {
            self.areaCode = value
        } else if let value = json["code"].string {
            self.areaCode = Int(value)!
        }

        if let value = json["areaName"].string {
            self.areaName = value
        } else if let value = json["name"].string {
            self.areaName = value
        }
        
        self.description = json["description"].string ?? ""
        
        if let gpsJSON = json["gps"] as JSON? {
            self.coordinates = Coordinates(json: gpsJSON)
        }
        
        if json["images"].exists() {
            let imagesJsonArrary:[JSON] = json["images"].arrayValue
            self.images = imagesJsonArrary.map { Image(json:$0) }
        }
        
        if json["bannerImages"].exists() {
            let imagesJsonArrary:[JSON] = json["bannerImages"].arrayValue
            self.images = imagesJsonArrary.map { Image(json:$0) }
        }
        
        if json["magazines"].exists() {
            let magazinesJsonArrary:[JSON] = json["magazines"].arrayValue
            self.magazines = magazinesJsonArrary.map { Magazine(json:$0) }
        }
    }
    
}
