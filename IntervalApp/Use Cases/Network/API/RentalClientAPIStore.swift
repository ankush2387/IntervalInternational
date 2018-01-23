//
//  RentalClientAPIStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/21/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import then
import DarwinSDK
import Foundation

protocol RentalClientAPIStore {
    func readTopTenDeals(for accessToken: DarwinAccessToken) -> Promise<[RentalDeal]>
    func readAllRentalAlerts(for accessToken: DarwinAccessToken) -> Promise<[RentalAlert]>
    func readRentalAlert(for accessToken: DarwinAccessToken, and alertId: Int64) -> Promise<RentalAlert>
    func readDates(for accessToken: DarwinAccessToken, and request: RentalSearchDatesRequest) -> Promise<RentalSearchDatesResponse>
}
