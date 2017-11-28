//
//  Advisement.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Advisement {
    
    open var category : String?
    open var title : String?
    open var description : String? = ""
    
    public init() {
    }
    
    // DREPRECATED ? - Confirm with Chandhi
    public convenience init(json:JSON){
        self.init()
        
        self.category = json["category"].string ?? ""
        self.title = json["title"].string ?? ""
        self.description = json["description"].string ?? ""
    }
    
    public convenience init(key:String,json:JSON){
        self.init()
        
        self.category = json["category"].string ?? ""
        self.title = json["title"].string ?? ""
        for innerDescription in (json["description"].arrayValue) {
            self.description = self.description?.appending(innerDescription.stringValue)
        }
    }
    
}
