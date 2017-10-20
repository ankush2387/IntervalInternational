//
//  PromiseErrorConversionSpec.swift
//  IntervalAppTests
//
//  Created by Aylwing Olivas on 10/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
import Quick
import Nimble

@testable import IntervalApp

final class PromiseErrorConversionSpec: QuickSpec {

    enum LoginError: String, ViewError {
        case accountExpired = "acountExpired"
        var description: (title: String, body: String) {
            switch self {
            case .accountExpired: return ("Login Error".localized(), "This account has expired.")
            }
        }
    }

    enum APIError: Error {
        case emptyDataError
        public var description: String {
            switch self {
            case .emptyDataError: return "Data Object is empty"
            }
        }
    }

    private func someAPIError() -> Promise<Void> {
        return Promise { _, reject in
            reject(APIError.emptyDataError)
        }
    }

    private func someViewError() -> Promise<Void> {
        return Promise { _, reject in
            reject(LoginError.accountExpired)
        }
    }

    override func spec() {

        describe("Promise onViewError extension testing") {

            it("returns a ViewError from an APIError") {
                self.someAPIError().onViewError { error in
                    expect(error is UserFacingCommonError).to(beTrue())
                    }.finally {}
            }

            it("returns the same ViewError") {
                self.someViewError().onViewError { error in
                    expect(error is LoginError).to(beTrue())
                    }.finally {}
            }
        }
    }
}
