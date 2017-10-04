//
//  TouchIDAuth.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
import Foundation
import LocalAuthentication

final class TouchIDAuth {

    // MARK: - Public properties
    var canEvaluatePolicy: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    // MARK: - Private properties
    private let context = LAContext()

    private enum TouchIDError: ViewError {

        case cannotEvaluatePolicy
        case authenticationFailed
        case userCancel
        case userFallback
        case unknown

        var description: (title: String, body: String) {

            switch self {

            case .cannotEvaluatePolicy:
                return ("Error".localized(), "Touch ID may not be configured.".localized())

            case .authenticationFailed:
                return ("Error".localized(), "There was a problem verifying your identity.".localized())

            case .userCancel:
                return ("Login cancelled".localized(), "")

            case .userFallback:
                return ("Manual Entry".localized(), "Please enter your password.".localized())

            default:
                return UserFacingCommonError.generic.description
            }
        }
    }

    func authenticateUser() -> Promise<Void> {

        return Promise { [unowned self] resolve, reject in

            guard self.canEvaluatePolicy else {
                reject(TouchIDError.cannotEvaluatePolicy)
                return
            }

            self.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                        localizedReason: "Logging in with Touch ID".localized()) { authenticated, error in

                                            guard error == nil else {

                                                switch error {
                                                case LAError.authenticationFailed?:
                                                    reject(TouchIDError.authenticationFailed)
                                                case LAError.userCancel?:
                                                    reject(TouchIDError.userCancel)
                                                case LAError.userFallback?:
                                                    reject(TouchIDError.userFallback)
                                                default:
                                                    reject(TouchIDError.unknown)
                                                }

                                                return
                                            }

                                            if authenticated {
                                                resolve()
                                            } else {
                                                reject(TouchIDError.authenticationFailed)
                                            }
            }
        }
    }
}
