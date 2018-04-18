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
    
    
    // This init method will intialize a resort object
    // given a summary JSON object
    //
    public convenience init(summaryJSON:JSON) {
        self.init()
        
        if let value = summaryJSON["code"].string {
            self.resortCode = value
        } else if let value = summaryJSON["resortCode"].string {
            self.resortCode = value
        }
        
        if let value = summaryJSON["name"].string {
            self.resortName = value
        } else if let value = summaryJSON["resortName"].string {
            self.resortName = value
        }
        
        self.areaCode = summaryJSON["areaCode"].intValue
        self.regionCode = summaryJSON["regionCode"].intValue
        self.groupCode = summaryJSON["groupCode"].string
        self.tier = summaryJSON["tier"].string?.lowercased()
        self.qualityResortRating = summaryJSON["qualityResortRating"].string
        self.allInclusive = summaryJSON["allInclusive"].boolValue
        self.allInclusiveChargesText = summaryJSON["allInclusiveChargesText"].string
        self.additionalCharges = summaryJSON["additionalCharges"].boolValue
        self.locked = summaryJSON["locked"].boolValue
        
        if let gpsJSON = summaryJSON["gps"] as JSON? {
            self.coordinates = Coordinates(json: gpsJSON)
        }
        
        if summaryJSON["address"].exists() {
            self.address = Address(json: summaryJSON["address"])
        }
        
        if summaryJSON["images"].exists() {
            let imagesArrary:[JSON] = summaryJSON["images"].arrayValue
            self.images = imagesArrary.map { Image(json:$0) }
        }
        
        if summaryJSON["children"].exists() {
            let childrenArrary:[JSON] = summaryJSON["children"].arrayValue
            self.children = childrenArrary.map { Resort(summaryJSON:$0) }
        }
        
        self.restrictedFromDate = summaryJSON["from"].string
        self.restrictedToDate = summaryJSON["to"].string
        
        if summaryJSON["reservationAttributes"].exists() {
            let reservationAttributesJsonArray:[JSON] = summaryJSON["reservationAttributes"].arrayValue
            self.reservationAttributes = reservationAttributesJsonArray.map { $0.string! }
        }
    }
    
    // This init method will intialize a resort object
    // given a detailed JSON object
    //
    public convenience init(detailJSON:JSON) {
        self.init(summaryJSON:detailJSON)
        
        self.description = detailJSON["description"].string
        self.allInclusive = detailJSON["allInclusive"].boolValue
        self.allInclusiveChargesText = detailJSON["allInclusiveChargesText"].string
        self.additionalCharges = detailJSON["additionalCharges"].boolValue
        self.golf = detailJSON["golf"].boolValue
        self.hasVideos = detailJSON["hasVideos"].boolValue
        self.phone = detailJSON["phone"].string
        self.fax = detailJSON["fax"].string
        self.checkInTime = detailJSON["checkInTime"].string
        self.checkOutTime = detailJSON["checkOutTime"].string
        self.webUrl = detailJSON["webUrl"].string
        
        if detailJSON["tdiChart"].exists() {
            let tdiChartJSON = detailJSON["tdiChart"] as JSON!
            self.tdiChart = TdiChart(json: tdiChartJSON!)
        }
        
        if detailJSON["inventory"].exists() {
            let inventoryJSON = detailJSON["inventory"] as JSON!
            self.inventory = Inventory(json: inventoryJSON!)
        }
        
        if detailJSON["rating"].exists() {
            let ratingJSON = detailJSON["rating"] as JSON!
            self.rating = ResortRating(json:ratingJSON!)
        }
        
        if detailJSON["nearestAirport"].exists() {
            let airportJSON = detailJSON["nearestAirport"] as JSON!
            self.nearestAiport = Airport(json: airportJSON!)
        }
        
        if detailJSON["amenities"].exists() {
            let amenitiesArray:[JSON] = detailJSON["amenities"].arrayValue
            self.amenities = amenitiesArray.map { ResortAmenity(json:$0) }
        }
        
        if detailJSON["advisements"].exists() {
            let advisementsArray:[JSON] = detailJSON["advisements"].arrayValue
            //self.advisements = advisementsArray.map { Advisement(key: "Advisement",json:$0["advisement"]) }
            self.advisements = advisementsArray.map { Advisement(json:$0) }
        }
        
        if detailJSON["videos"].exists() {
            let videosArrary:[JSON] = detailJSON["videos"].arrayValue
            self.videos = videosArrary.map { Video(json:$0) }
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
