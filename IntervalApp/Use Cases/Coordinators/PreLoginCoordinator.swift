//
//  PreLoginCoordinator.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import DarwinSDK

protocol PreLoginCoordinatorDelegate: class {
    func didLoad(token: DarwinAccessToken, settings: Settings)
    func didError()
}

final class PreLoginCoordinator {
    
    // MARK: - Public properties
    weak var delegate: PreLoginCoordinatorDelegate?

    // MARK: - Private properties
    private let supportClientAPIStore: SupportClientAPIStore
    private let authProviderClientAPIStore: AuthProviderClientAPIStore
    
    // MARK: - Private properties
    private var vacationSearchTypes: [String] {
        return [VacationSearchType.COMBINED, VacationSearchType.EXCHANGE, VacationSearchType.RENTAL].map { $0.rawValue }
    }
    
    // MARK: - Public functions
    func start() {
        readClientAccessToken()
    }

    // MARK: - Lifecycle
    init(authProviderClientAPIStore: AuthProviderClientAPIStore, supportClientAPIStore: SupportClientAPIStore) {
        self.authProviderClientAPIStore = authProviderClientAPIStore
        self.supportClientAPIStore = supportClientAPIStore
    }

    convenience init() {
        self.init(authProviderClientAPIStore: ClientAPI.sharedInstance, supportClientAPIStore: ClientAPI.sharedInstance)
    }
    
    // MARK: - Private functions
    private func readClientAccessToken() {
        authProviderClientAPIStore.readClientAccessToken()
            .then(onSuccess)
            .onError(onError)
    }
    
    private func onSuccess(darwinAccess: DarwinAccessToken) {
        
        if case .none = darwinAccess.token {
            delegate?.didError()
            return
        }

        let newVacationSearchSettings = VacationSearchSettings()

        let onSuccess = { [unowned self] (settings: Settings) in
            if case .some = settings.vacationSearch {
                self.delegate?.didLoad(token: darwinAccess, settings: settings)
            } else {
                newVacationSearchSettings.vacationSearchTypes = self.vacationSearchTypes
                settings.vacationSearch = newVacationSearchSettings
                self.delegate?.didLoad(token: darwinAccess, settings: settings)
            }
        }
        
        let onError = { [unowned self] (error: Error) in
            intervalPrint(error)
            let settings = Settings()
            settings.vacationSearch = newVacationSearchSettings
            settings.vacationSearch?.vacationSearchTypes = self.vacationSearchTypes
            self.delegate?.didLoad(token: darwinAccess, settings: settings)
        }

        supportClientAPIStore.readAppSettings(for: darwinAccess)
            .then(onSuccess)
            .onError(onError)
    }
    
    private func onError(error: Error) {
        intervalPrint(error)
        delegate?.didError()
    }
}
