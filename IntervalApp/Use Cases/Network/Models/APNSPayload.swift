//
//  APNSPayload.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/18/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

struct APNSPayload {

    // MARK: - Public properties
    let loginID: String
    let alertID: String
    let contactID: String
    let body: APNSPayloadBody
    let membershipNumber: String
}

extension APNSPayload {

    // MARK: - Lifecycle
    init(_ payload: [AnyHashable: Any]) {

        let json = JSON(payload.mapPairs { (String(describing: $0), $1) })
        loginID = json["login_id"].stringValue
        alertID = json["alert_id"].stringValue
        contactID = json["contact_id"].stringValue
        membershipNumber = json["membership_number"].stringValue
        body = APNSPayloadBody(json["aps"].dictionaryObject)
    }
}
