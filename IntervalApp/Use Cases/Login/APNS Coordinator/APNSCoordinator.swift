//
//  APNSCoordinator.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/21/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

protocol APNSCoordinatorDelegate: class {
    func redirectUser()
    func showRedirectAlert(with title: String, message: String)
}

final class APNSCoordinator {

    // MARK: - Public properties
    private (set) var payload: APNSPayload?
    weak var delegate: APNSCoordinatorDelegate?
    private (set) var shouldRedirectOnlogin = false
    var pushViabilityHasNotExpired: Bool {
        guard let dateAPNSRecieved = dateAPNSRecieved else { return false }
        return dateAPNSRecieved.numberOfMinutesElapsedFromDate < 15
    }

    // MARK: - Private property
    private var appState: AppState?
    private var userIsLoggedIn: Bool?
    private var dateAPNSRecieved: Date?

    // MARK: - Public function
    func start(payload: APNSPayload, appState: AppState, userIsLoggedIn: Bool) {
        self.payload = payload
        self.appState = appState
        self.userIsLoggedIn = userIsLoggedIn
        self.dateAPNSRecieved = Date()
        checkIfShouldRedirect()
    }

    func reset() {
        payload = nil
        appState = nil
        userIsLoggedIn = nil
        dateAPNSRecieved = nil
    }

     // MARK: - Private function
    private func checkIfShouldRedirect() {

        if let appState = appState, let userIsLoggedIn = userIsLoggedIn, let payload = payload {
            switch (appState, userIsLoggedIn, pushViabilityHasNotExpired) {

            case (.foreground, true, true):
                delegate?.showRedirectAlert(with: payload.body.title, message: payload.body.message + "\nTap for more information".localized())

            case (.foreground, false, true):
                delegate?.showRedirectAlert(with: payload.body.title, message: payload.body.message + "\nYou will be redirected on your next login!".localized())
                shouldRedirectOnlogin = true

            case (.background, true, true):
                delegate?.showRedirectAlert(with: payload.body.title, message: payload.body.message + "\nTap for more information".localized())

            case (.background, false, true):
                shouldRedirectOnlogin = true

                // All other scenarios - do nothing

            case (.foreground, true, false):
                break

            case (.foreground, false, false):
                break

            case (.background, true, false):
                break

            case (.background, false, false):
                break
            }
        }
    }
}
