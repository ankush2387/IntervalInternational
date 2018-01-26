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

final class ClientAPI {

    // MARK: - Public properties
    static let sharedInstance = ClientAPI()

    // MARK: - Lifecycle
    private init() {
        DarwinSDK.sharedInstance.config(Config.sharedInstance.getEnvironment(),
                                        client: Config.sharedInstance.get(.DarwinClientKey),
                                        secret: Config.sharedInstance.get(.DarwinSecretKey),
                                        logger: Logger.sharedInstance)
    }
}

extension ClientAPI: SupportClientAPIStore {

    func readAppSettings(for accessToken: DarwinAccessToken) -> Promise<Settings> {
        return Promise { resolve, reject in
            SupportClient.getSettings(accessToken, onSuccess: resolve, onError: reject)
        }
    }
}

extension ClientAPI: AuthProviderClientAPIStore {

    func readClientAccessToken() -> Promise<DarwinAccessToken> {
        return Promise { resolve, reject in
            AuthProviderClient.getClientAccessToken(resolve, onError: reject)
        }
    }

    func readAccessToken(for userName: String, and password: String) -> Promise<DarwinAccessToken> {
        return Promise { resolve, reject in
            AuthProviderClient.getAccessToken(userName, password: password, onSuccess: resolve, onError: reject)
        }
    }
}

extension ClientAPI: UserClientAPIStore {

    func readCurrentProfile(for accessToken: DarwinAccessToken) -> Promise<Contact> {
        return Promise { resolve, reject in
            UserClient.getCurrentProfile(accessToken, onSuccess: resolve, onError: reject)
        }
    }

    // TODO FRANK REMOVE 
    func writeSelected(membership: Membership, for accessToken: DarwinAccessToken) -> Promise<Void> {
        return Promise { resolve, reject in
            UserClient.putSessionsUser(accessToken, member: membership, onSuccess: resolve, onError: reject)
        }
    }
}

extension ClientAPI: RentalClientAPIStore {

    func readTopTenDeals(for accessToken: DarwinAccessToken) -> Promise<[RentalDeal]> {
        return Promise { resolve, reject in
            RentalClient.getTop10Deals(accessToken, onSuccess: resolve, onError: reject)
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
}

extension ClientAPI: ExchangeClientAPIStore {

    func readMyUnits(for accessToken: DarwinAccessToken) -> Promise<MyUnits> {
        return Promise { resolve, reject in
            ExchangeClient.getMyUnits(accessToken, onSuccess: resolve, onError: reject)
        }
    }

    func readFlexchangeDeals(for accessToken: DarwinAccessToken) -> Promise<[FlexExchangeDeal]> {
        return Promise { resolve, reject in
            ExchangeClient.getFlexExchangeDeals(accessToken, onSuccess: resolve, onError: reject)
        }
    }
}

extension ClientAPI: DirectoryClientAPIStore {

    func readResort(for accessToken: DarwinAccessToken, and resortCode: String) -> Promise<Resort> {
        return Promise { resolve, reject in
            DirectoryClient.getResortDetails(accessToken, resortCode: resortCode, onSuccess: resolve, onError: reject)
        }
    }

    func readResortUnits(for accessToken: DarwinAccessToken, and resortCode: String) -> Promise<[InventoryUnit]> {
        return Promise { resolve, reject in
            DirectoryClient.getResortUnits(accessToken, resortCode: resortCode, onSuccess: resolve, onError: reject)
        }
    }

    func readResortClubPointChart(for accessToken: DarwinAccessToken, and resortCode: String) -> Promise<ClubPointsChart> {
        return Promise { resolve, reject in
            DirectoryClient.getResortClubPointsChart(accessToken, resortCode: resortCode, onSuccess: resolve, onError: reject)
        }
    }

    func readResorts(for accessToken: DarwinAccessToken, and clubCode: String) -> Promise<[Resort]> {
        return Promise { resolve, reject in
            DirectoryClient.getResortsByClub(accessToken, clubCode: clubCode, onSuccess: resolve, onError: reject)
        }
    }

    func readResortUnitSizes(for accessToken: DarwinAccessToken, and resortCode: String) -> Promise<[InventoryUnit]> {
        return Promise { resolve, reject in
            DirectoryClient.getResortUnitSizes(accessToken, resortCode: resortCode, onSuccess: resolve, onError: reject)
        }
    }
    
    func readResortCalendars(for accessToken: DarwinAccessToken, and resortCode: String, and relinquishmentYear: Int) -> Promise<[ResortCalendar]> {
        return Promise { resolve, reject in
            DirectoryClient.getResortCalendars(accessToken,
                                               resortCode: resortCode,
                                               year: relinquishmentYear,
                                               onSuccess: resolve, onError: reject)
        }
    }
}

extension ClientAPI: ImageAPIStore {

    func readImage(for url: URL) -> Promise<UIImage> {
        return Promise { resolve, reject in
            URLSession.shared.dataTask(with: url) { data, _, error in

                if let error = error {
                    reject(error)
                    return
                }

                guard let data = data, let image = UIImage(data: data) else {
                    reject(CommonErrors.emptyDataError)
                    return
                }

                resolve(image)

                }.resume()
        }
    }
}
