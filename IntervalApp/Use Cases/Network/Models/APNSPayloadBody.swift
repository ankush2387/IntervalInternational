//
//  APNSPayloadBody.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/18/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

struct APNSPayloadBody {

    // MARK: - Public properties
    let sound: String
    let badge: String
    let title: String
    let message: String
    let category: String
}

extension APNSPayloadBody {

    // MARK: - Lifecycle
    init(_ body: [String: Any]?) {

        let json = JSON(body as Any)
        sound = json["sound"].stringValue
        badge = json["badge"].stringValue
        category = json["category"].stringValue
        title = json["alert"]["title"].stringValue
        message = json["alert"]["body"].stringValue
    }
}
