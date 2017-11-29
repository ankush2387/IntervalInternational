//
//  Destination.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/21/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AreaOfInfluenceDestination {
    
    open var destinationId : String!
    open var aoiId : String!
    open var destinationName : String!
    open var address : Address?
    open lazy var images = [Image]()
    open var geoArea : GeoArea?
    open var sortOrderNum : Int64?
    
    public init() {
    }
    
    public convenience init(destinationId:String, aoiId:String) {
        self.init()
        
        self.destinationId = destinationId
        self.aoiId = aoiId
    }
    
    public convenience init(json:JSON) {
        self.init()
       
        self.destinationId = json["id"].string
        self.aoiId = json["aoiId"].string
        self.destinationName = json["name"].string

        if json["address"].exists() {
            self.address = Address(json: json["address"])
        }

        if json["images"].exists() {
            let imagesJsonArrary:[JSON] = json["images"].arrayValue
            self.images = imagesJsonArrary.map { Image(json:$0) }
        }
        
        if json["gpsNwSe"].exists() {
            let geoAreaJson:JSON = json["gpsNwSe"]
            self.geoArea = GeoArea(json: geoAreaJson)
        }
        
        self.sortOrderNum = json["sortOrderNum"].int64Value
    }
    
}
