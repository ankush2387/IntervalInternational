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
    private init() {
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

    func writeSelected(membership: Membership, for accessToken: DarwinAccessToken) -> Promise<Void> {
        return Promise { resolve, reject in
            UserClient.putSessionsUser(accessToken, member: membership, onSuccess: resolve, onError: reject)
        }
    }
    
    func readAllRentalAlerts(for accessToken: DarwinAccessToken) -> Promise<[RentalAlert]> {
        return Promise { resolve, reject in
            RentalClient.getAlerts(accessToken, onSuccess: resolve, onError: reject)
        }
    }
    
    func readRentalAlert(for accessToken: DarwinAccessToken, and alertId: Int64) -> Promise<RentalAlert> {
        return Promise { resolve, reject in
            RentalClient.getAlert(accessToken, alertId: alertId, onSuccess: resolve, onError: reject)
        }
    }
    
    func readDates(for accessToken: DarwinAccessToken, and request: RentalSearchDatesRequest) -> Promise<RentalSearchDatesResponse> {
        return Promise { resolve, reject in
            RentalClient.searchDates(accessToken, request: request, onSuccess: resolve, onError: reject)
        }
    }
    
    func readTopTenDeals(for accessToken: DarwinAccessToken) -> Promise<[RentalDeal]> {
        return Promise { resolve, reject in
            RentalClient.getTop10Deals(accessToken, onSuccess: resolve, onError: reject)
        }
    }

    func readFlexchangeDeals(for accessToken: DarwinAccessToken) -> Promise<[FlexExchangeDeal]> {
        return Promise { resolve, reject in
            ExchangeClient.getFlexExchangeDeals(accessToken, onSuccess: resolve, onError: reject)
        }
    }
}
