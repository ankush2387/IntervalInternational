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
    let clientTokenLoaded = Observable(false)
    let appSettings: Observable<AppSettings?>
    var didLogin: (() -> Void)?
    var fetchedMoreThanOneMembership = false

    var trimmedUserName: String? {
        return username.value?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var biometricAuthentication: BiometricAuthentication {
        return BiometricAuthentication()
    }
    
    var touchIDEnabled: Bool {
        let touchIDEnabled = (try? encryptedStore.getItem(for: Persistent.touchIDEnabled.key, ofType: Bool()) ?? false) ?? false
        let appHasPreviousLogin = (try? decryptedStore.getItem(for: Persistent.appHasPreviousLogin.key, ofType: Bool()) ?? false) ?? false
        return touchIDEnabled && appHasPreviousLogin
    }

    var biometricLoginTitle: String? {
        guard let biometricType = biometricAuthentication.biometricType else { return nil }
        return biometricType == .faceID ? "Sign in with Face ID".localized() : "Sign in with Touch ID".localized()
    }
    
    var versionLabel: (text: String?, isHidden: Bool) {
        
        switch darwinSDK.apiEnvironment {
            
        case .production:
            return (nil, true)
            
        default:
            let environment = darwinSDK.apiEnvironment
            let text = "\("Version: ".localized()) \(appBundle.appVersion).\(appBundle.build) \(environment) (\(appBundle.gitCommit))"
            return (text, false)
        }
    }

    // MARK: - Private properties
    private let darwinSDK: DarwinSDK
    private let encryptedStore: EncryptedItemDataStore
    private let decryptedStore: DecryptedItemDataStore
    private let userClientAPIStore: UserClientAPIStore
    private let authProviderClientAPIStore: AuthProviderClientAPIStore
    private let disposeBag = DisposeBag()
    private var sessionStore: SessionStore
    
    // MARK: - Lifecycle
    init(backgroundImage: UIImage,
         sessionStore: SessionStore,
         userClientAPIStore: UserClientAPIStore,
         authProviderClientAPIStore: AuthProviderClientAPIStore,
         encryptedStore: EncryptedItemDataStore,
         decryptedStore: DecryptedItemDataStore,
         darwinSDK: DarwinSDK,
         appBundle: AppBundle) {

        appSettings = Observable(nil)
        self.appBundle = appBundle
        self.sessionStore = sessionStore
        self.darwinSDK = darwinSDK
        self.encryptedStore = encryptedStore
        self.decryptedStore = decryptedStore
        self.userClientAPIStore = userClientAPIStore
        self.backgroundImage = Observable(backgroundImage)
        self.authProviderClientAPIStore = authProviderClientAPIStore
        self.username = Observable(try? encryptedStore.getItem(for: Persistent.userName.key, ofType: String()).unwrappedString)
        self.password = Observable(try? encryptedStore.getItem(for: Persistent.password.key, ofType: String()).unwrappedString)
        self.clientTokenLoaded.observeNext(with: checkAppVersion).dispose(in: disposeBag)
    }

    // MARK: - Public functions
    func normalLogin() -> Promise<Void> {

        return Promise { [unowned self] _, reject in
            
            self.saveCredentials()
                .then(self.login(userName: self.trimmedUserName.unwrappedString, password: self.password.value.unwrappedString))
                .onError { error in
                    let message = (error as NSError).userInfo[NSLocalizedDescriptionKey]
                    let loginError = UserFacingCommonError.custom(title: "Error".localized(), body: message.unwrappedString)
                    reject(loginError)
                }
        }
    }
    
    func touchIDLogin() -> Promise<Void> {

        return Promise { [unowned self] _, reject in
            if let userName = try? self.encryptedStore.getItem(for: Persistent.userName.key, ofType: String()),
                let password = try? self.encryptedStore.getItem(for: Persistent.password.key, ofType: String()) {
                self.login(userName: userName.unwrappedString, password: password.unwrappedString).onError { _ in reject(UserFacingCommonError.generic) }
            } else {
                reject(UserFacingCommonError.custom(title: "Error".localized(), body: "It appears we could not find your credentials, please login normally once more.".localized()))
            }
        }
    }
    
    func didLoginUser() -> Promise<Void> {
        return Promise { [unowned self] _, reject in
            do {
                try self.decryptedStore.save(item: true, for: Persistent.appHasPreviousLogin.key)
                self.didLogin?()
            } catch {
                reject(error)
            }
        }
    }
    
    func readCurrentProfileForAccessToken(accessToken: DarwinAccessToken) -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in
            self.userClientAPIStore.readCurrentProfile(for: accessToken)
                .then { profile in
                    
                    guard let memberships = profile.memberships, profile.hasMembership() else {
                        reject(CommonErrors.errorWithSpecificMessage("No active membership"))
                        return
                    }
                    
                    // TODO: FRANK MAKE SURE MULTIPLE MEMEBERSHIPS ARE BEING SET
                    self.sessionStore.contact = profile
                    self.fetchedMoreThanOneMembership = memberships.count > 1
                    resolve()
                }
                .onError(reject)
        }
    }

    // MARK: - Private functions
    private func saveCredentials() -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in
            do {
                try self.encryptedStore.save(item: self.trimmedUserName.unwrappedString, for: Persistent.userName.key)
                try self.encryptedStore.save(item: self.password.value.unwrappedString, for: Persistent.password.key)
                resolve()
            } catch {
                reject(error)
            }
        }
    }
    
    private func login(userName: String, password: String) -> Promise<Void> {
        return Promise { [unowned self] resolve, reject in
            
            self.authProviderClientAPIStore.readAccessToken(for: userName, and: password)
                .then(self.saveUserAccessToken)
                .then(self.readCurrentProfileForAccessToken)
                .then(self.didLoginUser)
                .then(resolve)
                .onError(reject)
        }
    }

    private func saveUserAccessToken(token: DarwinAccessToken) -> Promise<DarwinAccessToken> {
        sessionStore.userAccessToken = token
        return Promise.resolve(token)
    }
    
    private func checkAppVersion(clientTokenLoaded: Bool) {
        if clientTokenLoaded {
            appSettings.next(sessionStore.appSettings?.ios)
        }
    }
}
