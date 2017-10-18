//
//  LoginViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
import Bond
import DarwinSDK
import Foundation
import ReactiveKit

final class LoginViewModel {
    
    // MARK: - Public properties
    let backgroundImage: Observable<UIImage>
    let username: Observable<String?>
    let password: Observable<String?>
    let isLoggingIn = Observable(false)
    let touchIDEnabled: Observable<Bool>
    let clientTokenLoaded = Observable(false)
    let appSettings: Observable<AppSettings?>
    var didLogin: (() -> Void)?

    var buttonEnabledState: Signal<Bool, NoError> {
        return combineLatest(username, password, isLoggingIn)
            .map(shouldDisableButton)
            .observeOn(.main)
    }

    // MARK: - Private properties
    private let encryptedStore: EncryptedStore
    private let clientAPIStore: ClientAPIStore
    private let touchIDUserNameKey = "touchIDUser"
    private let touchIDPasswordKey = "touchIDPass"
    private let disposeBag = DisposeBag()
    private var sessionStore: SessionStore
    private var persistentSettingsStore: PersistentSettingsStore
    
    // MARK: - Lifecycle
    init(backgroundImage: UIImage,
         sessionStore: SessionStore,
         clientAPIStore: ClientAPIStore,
         encryptedStore: EncryptedStore,
         persistentSettingsStore: PersistentSettingsStore) {

        appSettings = Observable(nil)
        self.sessionStore = sessionStore
        self.clientAPIStore = clientAPIStore
        self.encryptedStore = encryptedStore
        self.backgroundImage = Observable(backgroundImage)
        self.persistentSettingsStore = persistentSettingsStore
        self.touchIDEnabled = Observable(persistentSettingsStore.touchIDEnabled)
        self.username = Observable(try? encryptedStore.getItem(for: touchIDUserNameKey) ?? "")
        self.password = Observable(try? encryptedStore.getItem(for: touchIDPasswordKey) ?? "")
        self.touchIDEnabled.observeNext(with: updatedTouchIDState).dispose(in: disposeBag)
        self.clientTokenLoaded.observeNext(with: checkAppVersion).dispose(in: disposeBag)
    }

    // MARK: - Public functions
    func login() -> Promise<Void> {
        isLoggingIn.value = true
        return Promise { [unowned self] resolve, reject in
            self.saveCredentials()
                .then(self.clientAPIStore.readAccessToken(for: self.username.value.unwrappedString, and: self.password.value.unwrappedString))
                .then(self.saveUserAccessToken)
                .then(self.didLoginUser)
                .then(resolve)
                .onError { _ in reject(UserFacingCommonError.generic) }
                .finally(self.userIsNotLogginIn)
        }
    }
    
    func didLoginUser() {
        didLogin?()
    }

    // MARK: - Private functions
    private func saveCredentials() -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in
            do {
                try self.encryptedStore.save(item: self.username.value.unwrappedString, for: Persistent.userName.key)
                try self.encryptedStore.save(item: self.password.value.unwrappedString, for: Persistent.password.key)
                resolve()
            } catch {
                reject(error)
            }
        }
    }

    private func userIsNotLogginIn() {
        isLoggingIn.next(false)
    }

    private func saveUserAccessToken(token: DarwinAccessToken) {
        sessionStore.userAccessToken = token
    }

    private func shouldDisableButton(_ username: String?, password: String?, loggingIn: Bool) -> Bool {
        return username?.isEmpty == false && password?.isEmpty == false && !loggingIn
    }

    private func updatedTouchIDState(enabled: Bool) {
        persistentSettingsStore.touchIDEnabled = enabled
    }
    
    private func checkAppVersion(clientTokenLoaded: Bool) {
        if clientTokenLoaded {
            appSettings.next(sessionStore.appSettings?.ios)
        }
    }
}
