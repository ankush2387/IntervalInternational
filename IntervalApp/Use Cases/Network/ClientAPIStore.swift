//
//  ClientAPIStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/13/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
import DarwinSDK
import Foundation

protocol ClientAPIStore {
    func readClientAccessToken() -> Promise<DarwinAccessToken>
    func readMyUnits(for accessToken: DarwinAccessToken) -> Promise<MyUnits>
    func readAppSettings(for accessToken: DarwinAccessToken) -> Promise<Settings>
    func readCurrentProfile(for accessToken: DarwinAccessToken) -> Promise<Contact>
    func readTopTenDeals(for accessToken: DarwinAccessToken) -> Promise<[RentalDeal]>
    func readAllRentalAlerts(for accessToken: DarwinAccessToken) -> Promise<[RentalAlert]>
    func readFlexchangeDeals(for accessToken: DarwinAccessToken) -> Promise<[FlexExchangeDeal]>
    func readAccessToken(for userName: String, and password: String) -> Promise<DarwinAccessToken>
    func writeSelected(membership: Membership, for accessToken: DarwinAccessToken) -> Promise<Void>
    func readRentalAlert(for accessToken: DarwinAccessToken, and alertId: Int64) -> Promise<RentalAlert>
    func readDates(for accessToken: DarwinAccessToken, and request: RentalSearchDatesRequest) -> Promise<RentalSearchDatesResponse>
}
