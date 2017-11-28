//
//  MapSelection.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 8/25/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class MapSelection {
    
    open var name : String = ""
    open lazy var coordinates = [[Double]]()
    open var sortOrderNum : Int?
    
    public init(){
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.name = json["name"].stringValue
        
        /*
        if let coordinates = json["coordinates"].array {
            self.polygon = coordinates.map {
                let a = $0.arrayValue
                return Coordinates(latitude: a[0].doubleValue, longitude: a[1].doubleValue)
            }
        }
        */
        
        
        if let coordinates = json["coordinates"].array {
            self.coordinates = coordinates.map {
                let geoCoordinatePair = $0.arrayValue
                return [geoCoordinatePair[0].doubleValue, geoCoordinatePair[1].doubleValue]
            }
        }

        self.sortOrderNum = json["sortOrderNum"].intValue
    }
    
    open func transformToIntervalGeoCoordinates() -> [Coordinates] {
        return self.coordinates.map {
            return Coordinates(latitude: $0[0], longitude: $0[1])
        }
    }
    
}







