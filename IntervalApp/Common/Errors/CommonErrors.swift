//
//  CommonErrors.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/30/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

enum CommonErrors: Error {

    case unsupportedData
    case emptyInstance
    case parsingError
    case networkError(Int)
    case nilDataError
    case emptyDataError
    case errorWithSpecificMessage(String)
    case otherNSError(NSError?)
    
    public var description: String {
        switch self {
        case .unsupportedData: return "Error occured while working with a non supported data type"
        case .emptyInstance: return "Error occured while accessing object"
        case .parsingError: return "Error occurred while parsing the JSON"
        case let .networkError(errorValue): return "A network error of value \(errorValue) was thrown"
        case .nilDataError: return "Data Object is nil"
        case .emptyDataError: return "Data Object is empty"
        case let .errorWithSpecificMessage(message): return "An error was thrown with the message \(message)"
        case let .otherNSError(error):
            if let error = error {
                return "An NSError of code: \(error.code) with description: \(error.localizedDescription)"
            } else {
                return "Unknown error thrown."
            }
        }
    }
}
