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
    weak var delegate: APNSCoordinatorDelegate?
    private (set) var shouldRedirectOnlogin = false
    var pushViabilityHasNotExpired: Bool { return dateAPNSRecieved.numberOfMinutesElapsedFromDate < 15 }

    // MARK: - Private property
    private let appState: AppState
    private let userIsLoggedIn: Bool
    private let payload: APNSPayload
    private let dateAPNSRecieved: Date

    // MARK: - Lifecycle
    init(payload: APNSPayload, appState: AppState, userIsLoggedIn: Bool, dateAPNSRecieved: Date) {
        self.payload = payload
        self.appState = appState
        self.userIsLoggedIn = userIsLoggedIn
        self.dateAPNSRecieved = dateAPNSRecieved
    }

    // MARK: - Public function
    func start() {

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
