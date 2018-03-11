//
//  BiometricAuthentication.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
import Foundation
import LocalAuthentication

final class BiometricAuthentication {

    // MARK: - Public properties
    enum BiometricAuthenticationType { case faceID, touchID }
    
    var canEvaluatePolicy: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    var biometricType: BiometricAuthenticationType? {
        guard canEvaluatePolicy else { return nil }
        guard #available(iOS 11.0, *) else { return .touchID }
        
        switch context.biometryType {
        case .none:
            return nil
            
        case .faceID:
            return .faceID
            
        case .touchID:
            return .touchID
        }
    }

    // MARK: - Private properties
    private let context = LAContext()

    private enum BiometricError: ViewError {

        case cannotEvaluatePolicy
        case authenticationFailed
        case userCancel
        case userFallback
        case unknown

        var description: (title: String, body: String) {

            switch self {

            case .cannotEvaluatePolicy:
                return ("Touch ID Isn't Set Up On This Device".localized(),
                        "To set up Touch ID on this device, go to Settings > Touch ID & Passcode and add a valid fingerprint.".localized())

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
                reject(BiometricError.cannotEvaluatePolicy)
                return
            }

            if #available(iOS 11.0, *), self.context.biometryType == .faceID {
                self.authenticateWith(localizedReason: "Logging in with Face ID".localized())
                    .then(resolve)
                    .onError(reject)
            } else {
                self.authenticateWith(localizedReason: "Logging in with Touch ID".localized())
                    .then(resolve)
                    .onError(reject)
            }
        }
    }
    
    private func authenticateWith(localizedReason: String) -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in
            self.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                        localizedReason: localizedReason) { authenticated, error in
                                            
                                            guard error == nil else {
                                                
                                                switch error {
                                                case LAError.authenticationFailed?:
                                                    reject(BiometricError.authenticationFailed)
                                                case LAError.userCancel?:
                                                    reject(BiometricError.userCancel)
                                                case LAError.userFallback?:
                                                    reject(BiometricError.userFallback)
                                                default:
                                                    reject(BiometricError.unknown)
                                                }
                                                
                                                return
                                            }
                                            
                                            if authenticated {
                                                resolve()
                                            } else {
                                                reject(BiometricError.authenticationFailed)
                                            }
            }
        }
    }
}
