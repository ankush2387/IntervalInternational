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
    open lazy var description = [String]()
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.category = json["category"].string ?? ""
        self.title = json["title"].string ?? ""
        
        if json["description"].exists() {
            let descriptionArray:[JSON] = json["description"].arrayValue
            self.description = descriptionArray.map { $0.string! }
        }
    }
    
}
