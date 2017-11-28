//
//  DestinationsRequest.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/22/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation

open class SearchDestinationsRequest {

    open var query : String?
    
    public init() {
    }

    public convenience init(query: String!) {
        self.init()
        
        self.query = query
    }
    
}
