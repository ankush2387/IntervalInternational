//
//  GeoArea.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/13/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

open class GeoArea {
    
    open var northWestCoordinate: Coordinates?
    open var southEastCoordinate: Coordinates?
    open var maximunOfMiles: Int? = 200
    
    public init() {
    }
    
    public convenience init(_ northWestCoordinate: Coordinates, _ southEastCoordinate: Coordinates) {
        self.init()
        
        self.northWestCoordinate = northWestCoordinate
        self.southEastCoordinate = southEastCoordinate
    }
    
    public convenience init(nwLat: CLLocationDegrees, nwLon: CLLocationDegrees, seLat: CLLocationDegrees, seLon: CLLocationDegrees) {
        self.init(Coordinates(latitude: nwLat, longitude: nwLon), Coordinates(latitude: seLat, longitude: seLon))
    }
    
    public convenience init(nw: CLLocation, se: CLLocation) {
        self.init(nwLat: nw.coordinate.latitude, nwLon: nw.coordinate.longitude, seLat: se.coordinate.latitude, seLon: se.coordinate.longitude)
    }

    public convenience init(json:JSON) {
        self.init()
        
        if json["northwest"].exists() {
            let northWestCoordinateJson:JSON = json["northwest"]
            self.northWestCoordinate = Coordinates(json: northWestCoordinateJson)
        }
        
        if json["southeast"].exists() {
            let southEastCoordinateJson:JSON = json["southeast"]
            self.southEastCoordinate = Coordinates(json: southEastCoordinateJson)
        }
    }
    
}
