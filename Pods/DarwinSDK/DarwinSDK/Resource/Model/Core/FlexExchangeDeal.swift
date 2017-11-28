//
//  FlexExchangeDeal.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 8/16/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class FlexExchangeDeal {
    
    open var name : String?
    open var description : String?
    open var areaCode : Int = 0
    open var coordinates : Coordinates?
    open lazy var images = [Image]()
    open lazy var bannerImages = [Image]()
    open lazy var magazines = [Magazine]()
   
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        self.name = json["name"].string ?? ""
        self.description = json["description"].string ?? ""
        self.areaCode = json["code"].intValue
        
        if let gpsJSON = json["gps"] as JSON? {
            self.coordinates = Coordinates(json: gpsJSON)
        }

        if json["images"].exists() {
            let imagesArray:[JSON] = json["images"].arrayValue
            self.images = imagesArray.map { Image(json:$0) }
        }
        
        if json["bannerImages"].exists() {
            let bannerImagesArray:[JSON] = json["bannerImages"].arrayValue
            self.bannerImages = bannerImagesArray.map { Image(json:$0) }
        }
        
        if json["magazines"].exists() {
            let magazinesArray:[JSON] = json["magazines"].arrayValue
            self.magazines = magazinesArray.map { Magazine(json:$0) }
        }
    }
    
    open func getCheckInFromDate() -> Date {
        return Date().plusDays(1)
    }
    
    open func getCheckInToDate() -> Date {
        let tomorrow = Date().plusDays(1)
        return tomorrow.plusDays(59)
    }
    
    open func getCheckInDate() -> Date {
        // Derive a date in the middle of: tomorrow and tomorrow+59
        let tomorrow = Date().plusDays(1)
        let plus59 = tomorrow.plusDays(59)
        let middle =  tomorrow.daysBetween(to: plus59) / 2;
        
        return tomorrow.plusDays(middle)
    }
}
