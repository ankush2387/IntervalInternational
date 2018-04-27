//
//  Resort.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/1/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Resort {
    
    open var resortCode : String?
    open var resortName : String?
    open var description : String?
    open var address : Address?
    open var phone : String?
    open var fax : String?
    open var checkInTime : String?
    open var checkOutTime : String?
    open var regionCode : Int = 0
    open var areaCode : Int = 0
    open var groupCode : String?
    open var rating : ResortRating?
    open var tdiChart : TdiChart?
    open var webUrl : String?
    open var tier : String?
    open var qualityResortRating : String?
    open var nearestAiport : Airport?
    open var coordinates : Coordinates?
    open var allInclusive : Bool = false
    open var allInclusiveChargesText : String?
    open var additionalCharges : Bool = false
    open var hasVideos : Bool?
    open var golf : Bool = false
    open var locked : Bool = false
    open lazy var images = [Image]()
    open lazy var videos = [Video]()
    open lazy var amenities = [ResortAmenity]()
    open lazy var advisements = [Advisement]()
    open var inventory : Inventory?
    open lazy var children = [Resort]()
    open var restrictedFromDate : String?
    open var restrictedToDate : String?
    open lazy var reservationAttributes = [String]() // ReservationAttribute
    
    public init() {
    }
    
    public convenience init(resortCode:String?) {
        self.init()
        self.resortCode = resortCode
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        if let value = json["code"].string {
            self.resortCode = value
        } else if let value = json["resortCode"].string {
            self.resortCode = value
        }
        
        if let value = json["name"].string {
            self.resortName = value
        } else if let value = json["resortName"].string {
            self.resortName = value
        }
        
        self.areaCode = json["areaCode"].intValue
        self.regionCode = json["regionCode"].intValue
        self.groupCode = json["groupCode"].string
        self.tier = json["tier"].string?.lowercased()
        self.qualityResortRating = json["qualityResortRating"].string
        self.allInclusive = json["allInclusive"].boolValue
        self.allInclusiveChargesText = json["allInclusiveChargesText"].string
        self.additionalCharges = json["additionalCharges"].boolValue
        self.locked = json["locked"].boolValue
        self.description = json["description"].string
        self.allInclusive = json["allInclusive"].boolValue
        self.allInclusiveChargesText = json["allInclusiveChargesText"].string
        self.additionalCharges = json["additionalCharges"].boolValue
        self.golf = json["golf"].boolValue
        self.hasVideos = json["hasVideos"].boolValue
        self.phone = json["phone"].string
        self.fax = json["fax"].string
        self.checkInTime = json["checkInTime"].string
        self.checkOutTime = json["checkOutTime"].string
        self.webUrl = json["webUrl"].string
        
        if let gpsJSON = json["gps"] as JSON? {
            self.coordinates = Coordinates(json: gpsJSON)
        }
        
        if json["address"].exists() {
            self.address = Address(json: json["address"])
        } else {
            self.address = Address()
            self.address?.cityName = json["cityName"].string
            self.address?.territoryCode = json["territoryCode"].string
            self.address?.countryCode = json["countryCode"].string
        }
        
        if json["images"].exists() {
            let imagesArrary:[JSON] = json["images"].arrayValue
            self.images = imagesArrary.map { Image(json:$0) }
        }
        
        if json["videos"].exists() {
            let videosArrary:[JSON] = json["videos"].arrayValue
            self.videos = videosArrary.map { Video(json:$0) }
        }
        
        if json["tdiChart"].exists() {
            let tdiChartJSON = json["tdiChart"] as JSON!
            self.tdiChart = TdiChart(json: tdiChartJSON!)
        }
        
        if json["inventory"].exists() {
            let inventoryJSON = json["inventory"] as JSON!
            self.inventory = Inventory(json: inventoryJSON!)
        }
        
        if json["rating"].exists() {
            let ratingJSON = json["rating"] as JSON!
            self.rating = ResortRating(json:ratingJSON!)
        }
        
        if json["nearestAirport"].exists() {
            let airportJSON = json["nearestAirport"] as JSON!
            self.nearestAiport = Airport(json: airportJSON!)
        }
        
        if json["amenities"].exists() {
            let amenitiesArray:[JSON] = json["amenities"].arrayValue
            self.amenities = amenitiesArray.map { ResortAmenity(json:$0) }
        }
        
        if json["advisements"].exists() {
            let advisementsArray:[JSON] = json["advisements"].arrayValue
            //self.advisements = advisementsArray.map { Advisement(key: "Advisement",json:$0["advisement"]) }
            self.advisements = advisementsArray.map { Advisement(json:$0) }
        }
        
        if json["children"].exists() {
            let childrenArrary:[JSON] = json["children"].arrayValue
            self.children = childrenArrary.map { Resort(json:$0) }
        }
        
        self.restrictedFromDate = json["from"].string
        self.restrictedToDate = json["to"].string
        
        if json["reservationAttributes"].exists() {
            let reservationAttributesJsonArray:[JSON] = json["reservationAttributes"].arrayValue
            self.reservationAttributes = reservationAttributesJsonArray.map { $0.string! }
        }
    }
    
    open func getImages( _ size:ImageSize ) -> [Image]? {
        return self.images.filter { $0.size == size.rawValue }
    }
    
    open func getDefaultImage( _ size:ImageSize ) -> Image? {
        return self.images.filter { $0.size == size.rawValue }.first
    }
    
    open func getDefaultImage() -> Image? {
        if let image = getDefaultImage(ImageSize.XLARGE) {
            return image
        } else if let image = getDefaultImage(ImageSize.LARGE) {
            return image
        } else if let image = getDefaultImage(ImageSize.THUMBNAIL) {
            return image
        } else if let image = getDefaultImage(ImageSize.TYNY) {
            return image
        } else {
            return nil
        }
    }
    
}

