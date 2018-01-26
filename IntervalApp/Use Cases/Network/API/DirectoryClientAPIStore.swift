//
//  DirectoryClientAPIStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/21/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import then
import DarwinSDK
import Foundation

protocol DirectoryClientAPIStore {
    func readResort(for accessToken: DarwinAccessToken, and resortCode: String) -> Promise<Resort>
    func readResorts(for accessToken: DarwinAccessToken, and clubCode: String) -> Promise<[Resort]>
    func readResortUnits(for accessToken: DarwinAccessToken, and resortCode: String) -> Promise<[InventoryUnit]>
    func readResortClubPointChart(for accessToken: DarwinAccessToken, and resortCode: String) -> Promise<ClubPointsChart>
    func readResortUnitSizes(for accessToken: DarwinAccessToken, and resortCode: String) -> Promise<[InventoryUnit]>
    func readResortCalendars(for accessToken: DarwinAccessToken, and resortCode: String, and relinquishmentYear: Int) -> Promise<[ResortCalendar]>
}
