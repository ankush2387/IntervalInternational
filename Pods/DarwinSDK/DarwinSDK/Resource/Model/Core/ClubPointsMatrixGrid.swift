//
//  ClubPointsMatrixGrid.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 11/19/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ClubPointsMatrixGrid {
    
    open var fromDate : String?
    open var toDate : String?
    open lazy var rows = [ClubPointsMatrixGridRow]()
    
    public init() {
    }
    
    public convenience init(json:JSON){
        self.init()
        
        self.fromDate = json["fromDate"].string ?? ""
        self.toDate = json["toDate"].string ?? ""
        
        if json["rows"].exists() {
            let rowsJsonArray:[JSON] = json["rows"].arrayValue
            self.rows = rowsJsonArray.map { ClubPointsMatrixGridRow(json:$0) }
        }
        
    }
    
}
