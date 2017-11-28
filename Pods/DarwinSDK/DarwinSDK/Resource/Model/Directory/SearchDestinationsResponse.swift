//
//  DestinationResponse.swift
//  DarwinSDK
//
//  Created by Ralph Fiol on 4/22/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class SearchDestinationsResponse {
    
    open lazy var resorts = [Resort]()
    open lazy var destinations = [AreaOfInfluenceDestination]()
    
    public init() {
    }

    public convenience init(json:JSON) {
        self.init();

		if json["resorts"].exists() {
			let resortsArray:[JSON] = json["resorts"].arrayValue
            self.resorts = resortsArray.map { Resort(summaryJSON:$0) }
        }

		if json["destinations"].exists() {
			let destinationsArray:[JSON] = json["destinations"].arrayValue
            self.destinations = destinationsArray.map { AreaOfInfluenceDestination(json:$0) }
        }
    }
    
}
