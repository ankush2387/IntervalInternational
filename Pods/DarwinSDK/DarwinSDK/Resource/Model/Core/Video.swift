//
//  Video.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Video {

    open var id : String?
    open var externalRefId : String?
    open var name : String?
    open var subtitle : String?
    open var duration : Int = 0
    open var featured : Bool = false
    open var category : String?
    open lazy var images = [Image]()
    open lazy var resortCodes = [String]()
    open lazy var areaCodes = [Int]()
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()

        self.id = json["id"].string ?? ""
        self.externalRefId = json["externalRefId"].string ?? ""
        self.name = json["name"].string ?? ""
        self.subtitle = json["subtitle"].string ?? ""
        self.duration = json["duration"].intValue
        self.featured = json["featured"].boolValue
        self.category = json["category"].string ?? ""
        
        if json["images"].exists() {
            let imagesJsonArrary:[JSON] = json["images"].arrayValue
            self.images = imagesJsonArrary.map { Image(json:$0) }
        }
        
        if json["resortCodes"].exists() {
            let resortCodesJsonArray:[JSON] = json["resortCodes"].arrayValue
            self.resortCodes = resortCodesJsonArray.map { $0.stringValue }
        }
        
        if json["areaCodes"].exists() {
            let areaCodesJsonArray:[JSON] = json["areaCodes"].arrayValue
            self.areaCodes = areaCodesJsonArray.map { $0.intValue }
        }
    }
    
}

