//
//  RentalProcessRecapResponse.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/10/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RentalProcessRecapResponse {
    
    // TODO (Frank): Validate if this processId is equal to RentalProccess.processId
    open var processId : Int = 0
    open var step : ProcessStep?
    // TODO (Frank): Remove RecapView
    open var view : RecapView?
    
    public init() {
    }
    
    public convenience init(json:JSON) {
        self.init()
        
        if let value = json["id"].int {
            self.processId = value
        }
        
        self.step = ProcessStep.fromName(name: json["step"].string ?? "")
      
        if let viewJSON = json["view"] as JSON? {
            self.view = RecapView(json: viewJSON)
        }
    }
    
}

