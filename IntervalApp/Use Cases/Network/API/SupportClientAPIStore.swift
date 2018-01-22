//
//  SupportClientAPIStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/21/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import then
import DarwinSDK
import Foundation

protocol SupportClientAPIStore {
    func readAppSettings(for accessToken: DarwinAccessToken) -> Promise<Settings>
}
