//
//  ClubPointsMatrix.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/19/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ClubPointsMatrix {
    
    open var description : String?
    open lazy var grids = [ClubPointsMatrixGrid]()
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.description = json["description"].string ?? ""
        
        if json["grids"].exists() {
            let gridsJsonArray:[JSON] = json["grids"].arrayValue
            self.grids = gridsJsonArray.map { ClubPointsMatrixGrid(json:$0) }
        }
        
    }
    
}
