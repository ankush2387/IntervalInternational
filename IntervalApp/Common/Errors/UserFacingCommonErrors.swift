//
//  UserFacingCommonErrors.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

enum UserFacingCommonError: ViewError {

    case noData
    case generic
    case noNetConnection
    case noServerResponse
    case handleError(Any?)
    case custom(title: String, body: String)

    var description: (title: String, body: String) {
        switch self {

        case .noNetConnection:
            return ("Check Your Connection".localized(),
                    "You don't seem to have an active internet connection. Please check your connection.".localized())

        case .noData:
            return ("Data Error".localized(),
                    "Couldn't load data. If the problem persists, please contact Interval International.".localized())

        case .noServerResponse:
            return ("Server Error".localized(),
                    "Couldn't load data. If the problem persists, please contact Interval International.".localized())

        case .generic:
            return ("Error".localized(), "An error occurred. Please try again.".localized())
            
        case let .handleError(error?):
            
            if let error = error as? NSError {
               return ("Error".localized(), error.localizedDescription)
            } else if let error = error as? Error {
               return ("Error".localized(), error.localizedDescription)
            } else if let error = error as? ViewError {
                return error.description
            } else {
                return UserFacingCommonError.generic.description
            }
            
        case .handleError(.none):
            return UserFacingCommonError.generic.description
            
        case let .custom(title, body):
            return (title, body)
        }
    }
}
