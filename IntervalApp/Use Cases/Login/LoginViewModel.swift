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
    let appBundle: AppBundle
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
    
    var versionLabel: (text: String?, isHidden: Bool) {
        
        switch configuration.getEnvironment() {
            
        case .production, .production_dns:
            return (nil, true)
            
        default:
            let environment = configuration.get(.Environment, defaultValue: "NONE").uppercased()
            let text = "\("Version: ".localized()) \(appBundle.appVersion).\(appBundle.build) \(environment) (\(appBundle.gitCommit))"
            return (text, false)
        }
    }

    // MARK: - Private properties
    private let configuration: Config
    private let encryptedStore: EncryptedItemDataStore
    private let clientAPIStore: ClientAPIStore
    private let touchIDUserNameKey = "touchIDUser"
    private let touchIDPasswordKey = "touchIDPass"
    private let disposeBag = DisposeBag()
    private var sessionStore: SessionStore
    
    // MARK: - Lifecycle
    init(backgroundImage: UIImage,
         sessionStore: SessionStore,
         clientAPIStore: ClientAPIStore,
         encryptedStore: EncryptedItemDataStore,
         configuration: Config,
         appBundle: AppBundle) {

        appSettings = Observable(nil)
        self.appBundle = appBundle
        self.sessionStore = sessionStore
        self.configuration = configuration
        self.clientAPIStore = clientAPIStore
        self.encryptedStore = encryptedStore
        self.backgroundImage = Observable(backgroundImage)
        self.touchIDEnabled = Observable(((try? encryptedStore.getItem(for: Persistent.touchIDEnabled.key, ofType: Bool()) ?? false) ?? false))
        self.username = Observable(try? encryptedStore.getItem(for: Persistent.userName.key, ofType: String()).unwrappedString)
        self.password = Observable(try? encryptedStore.getItem(for: Persistent.password.key, ofType: String()).unwrappedString)
        self.touchIDEnabled.observeNext(with: updatedTouchIDState).dispose(in: disposeBag)
        self.clientTokenLoaded.observeNext(with: checkAppVersion).dispose(in: disposeBag)
    }

    // MARK: - Public functions
    func login() -> Promise<Void> {
        isLoggingIn.next(true)
        return Promise { [unowned self] resolve, reject in
            self.saveCredentials()
                .then(self.clientAPIStore.readAccessToken(for: self.username.value.unwrappedString, and: self.password.value.unwrappedString))
                .then(self.saveUserAccessToken)
                .then(self.readCurrentProfileForAccessToken)
                .then(self.didLoginUser)
                .then(resolve)
                .onError { _ in reject(UserFacingCommonError.generic) }
                .finally(self.userIsNotLogginIn)
        }
    }
    
    func didLoginUser() {
        didLogin?()
    }
    
    func readCurrentProfileForAccessToken(accessToken: DarwinAccessToken) -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in
            self.clientAPIStore.readCurrentProfile(for: accessToken)
                .then {
                    self.sessionStore.contact = $0
                    resolve()
                }
                .onError(reject)
        }
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

    private func saveUserAccessToken(token: DarwinAccessToken) -> Promise<DarwinAccessToken> {
        sessionStore.userAccessToken = token
        return Promise.resolve(token)
    }

    private func shouldDisableButton(_ username: String?, password: String?, loggingIn: Bool) -> Bool {
        return username?.isEmpty == false && password?.isEmpty == false && !loggingIn
    }

    private func updatedTouchIDState(enabled: Bool) {
        try? encryptedStore.save(item: enabled, for: Persistent.touchIDEnabled.key)
    }
    
    private func checkAppVersion(clientTokenLoaded: Bool) {
        if clientTokenLoaded {
            appSettings.next(sessionStore.appSettings?.ios)
        }
    }
}
