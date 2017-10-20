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
    func readAppSettings(for accessToken: DarwinAccessToken) -> Promise<Settings>
    func readAccessToken(for userName: String, and password: String) -> Promise<DarwinAccessToken>
}
