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
    open var duration : Int = 0
    open var type : String?
    open var code : String?
    open lazy var images = [Image]()
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()

        self.id = json["id"].string ?? ""
        self.externalRefId = json["externalRefId"].string ?? ""
        self.name = json["name"].string ?? ""
        self.duration = json["duration"].intValue
        
        if json["category"].exists() {
            let categoryJSON : JSON = json["category"] as JSON!
            self.type = categoryJSON["type"].string
            
            if (self.type == VideoCategory.Area.rawValue) {
                self.code = "\(categoryJSON["code"].intValue)"
            } else if (self.type == VideoCategory.Resort.rawValue) {
                self.code = categoryJSON["code"].string
            }
        }
        
        if json["images"].exists() {
            let imagesJsonArrary:[JSON] = json["images"].arrayValue
            self.images = imagesJsonArrary.map { Image(json:$0) }
        }
    }
    
}

