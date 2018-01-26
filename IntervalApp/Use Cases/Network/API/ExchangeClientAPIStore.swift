//
//  ExchangeClientAPIStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/21/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import then
import DarwinSDK
import Foundation

protocol ExchangeClientAPIStore {
    func readMyUnits(for accessToken: DarwinAccessToken) -> Promise<MyUnits>
    func readFlexchangeDeals(for accessToken: DarwinAccessToken) -> Promise<[FlexExchangeDeal]>
    func writeFixWeekReservation(for accessToken: DarwinAccessToken, relinquishmentID: String, reservation: FixWeekReservation) -> Promise<Void>
}
