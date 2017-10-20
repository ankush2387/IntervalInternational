//
//  UserFacingCommonErrors.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

enum UserFacingCommonError: ViewError {
    
    case noNetConnection
    case noServerResponse
    case generic
    
    var description: (title: String, body: String) {
        switch self {
        case .noNetConnection:
            return ("Check Your Connection".localized(),
                    "You don't seem to have an active internet connection. Please check your connection.".localized())
        case .noServerResponse:
            return ("Server Error".localized(),
                    "Couldn't load data. If the problem persists, please contact Interval International.".localized())
        case .generic:
            return ("Error".localized(), "An error occurred. Please try again.".localized())
        }
    }
}
