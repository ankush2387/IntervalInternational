//
//  ClientAPI.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/13/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
import DarwinSDK
import Foundation

final class ClientAPI: ClientAPIStore {

    // MARK: - Public properties
    static let sharedInstance = ClientAPI()

    // MARK: - Lifecycle
    init() {
        DarwinSDK.sharedInstance.config(Config.sharedInstance.getEnvironment(),
                                        client: Config.sharedInstance.get(.DarwinClientKey),
                                        secret: Config.sharedInstance.get(.DarwinSecretKey),
                                        logger: Logger.sharedInstance)
    }

    // MARK: - Public functions
    func readAppSettings(for accessToken: DarwinAccessToken) -> Promise<Settings> {
        return Promise { resolve, reject in
            SupportClient.getSettings(accessToken, onSuccess: resolve, onError: reject)
        }
    }

    func readAccessToken(for userName: String, and password: String) -> Promise<DarwinAccessToken> {
        return Promise { resolve, reject in
            AuthProviderClient.getAccessToken(userName, password: password, onSuccess: resolve, onError: reject)
        }
    }

    func readClientAccessToken() -> Promise<DarwinAccessToken> {
        return Promise { resolve, reject in
            AuthProviderClient.getClientAccessToken(resolve, onError: reject)
        }
    }
    
    func readCurrentProfile(for accessToken: DarwinAccessToken) -> Promise<Contact> {
        return Promise { resolve, reject in
            UserClient.getCurrentProfile(accessToken, onSuccess: resolve, onError: reject)
        }
    }
}
