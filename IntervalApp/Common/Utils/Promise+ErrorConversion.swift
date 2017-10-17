//
//  Promise+ErrorConversion.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
import Foundation

/// Protocol for Error objects to add a description property so they can be sent to presentErrorAlert
protocol ViewError: Error {

    /// Sets a tuple for the title and body that will be shown on the error alert
    var description: (title: String, body: String) { get }
}

extension Promise {

    /// Error handler used for intercepting errors and converting them to ViewErrors
    ///
    /// - Parameter handler: Function that takes a ViewError object
    /// - Returns: A Promise with the original object
    @discardableResult
    func onViewError(handler: @escaping (ViewError) -> Void) -> Promise<T> {
        registerOnError { error in
            if let viewError = error as? ViewError {
                handler(viewError)
            } else {
                handler(UserFacingCommonError.generic)
            }
        }
        return self
    }
}
