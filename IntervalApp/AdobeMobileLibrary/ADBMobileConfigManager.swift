//
//  ADBMobileConfigManager.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 1/5/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

struct ADBMobileConfigManager {

    // MARK: - Public properties
    var isRunningInTestingEnvironment: Bool {
        switch intervalConfig.getEnvironment() {
        case .staging_dns, .staging, .qa1_dns, .qa2_dns, .qa2, .qa1, .omniture, .development2, .development:
            return true
        default:
            return false
        }
    }

    var customURLPathBeingUsed: Bool {

        guard let path = try? decryptedStore.getItem(for: Persistent.adobeMobileConfigCustomURL.key, ofType: String()) else {
            return false
        }

        return !path.unwrappedString.isEmpty
    }

    var base: String? {
        guard let customServerURL = try? decryptedStore.getItem(for: Persistent.adobeMobileConfigCustomURL.key, ofType: String()),
            !customServerURL.unwrappedString.isEmpty else {
                return nil
        }

        return customServerURL?.components(separatedBy: ":").first
    }

    var port: String? {
        guard let customServerURL = try? decryptedStore.getItem(for: Persistent.adobeMobileConfigCustomURL.key, ofType: String()),
            !customServerURL.unwrappedString.isEmpty else {
                return nil
        }
        return customServerURL?.components(separatedBy: ":").last
    }

    var configFilePathURL: String? {

        guard let path = try? decryptedStore.getItem(for: Persistent.adobeMobileConfigCustomURL.key, ofType: String()),
            !path.unwrappedString.isEmpty else {
                return directoryForOriginalConfigFile?.path
        }

        return filename?.path
    }

    // MARK: - Private properties
    private let intervalConfig: Config
    private let decryptedStore: DecryptedItemDataStore
    private let directoryForOriginalConfigFile = Bundle.main.url(forResource: "ADBMobileConfig", withExtension: "json")
    private var filename: URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.last?.appendingPathComponent("ADBMobileConfig.json")
    }

    // MARK: - Lifecycle
    init(decryptedStore: DecryptedItemDataStore, intervalConfig: Config) {
        self.decryptedStore = decryptedStore
        self.intervalConfig = intervalConfig
    }

    init() {
        self.init(decryptedStore: UserDafaultsWrapper(), intervalConfig: Config.sharedInstance)
    }

    // MARK: - Public functions
    /// Sets a custom Omniture URL
    func set(serverURL: String) throws {

        guard let url = directoryForOriginalConfigFile else {
            throw CommonErrors.parsingError
        }

        guard let data = try? Data(contentsOf: url) else {
            throw CommonErrors.nilDataError
        }

        do {

            guard var object = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                throw CommonErrors.parsingError
            }

            guard var analytics = object["analytics"] as? [String: Any] else {
                throw CommonErrors.parsingError
            }

            analytics["server"] = serverURL
            analytics["ssl"] = !serverURL.contains(":")
            object["analytics"] = analytics

            guard JSONSerialization.isValidJSONObject(object) else {
                throw CommonErrors.unsupportedData
            }

            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)

            guard let json = jsonString else {
                throw CommonErrors.parsingError
            }

            guard let filename = filename else {
                throw CommonErrors.emptyInstance
            }

            try json.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            try decryptedStore.save(item: serverURL, for: Persistent.adobeMobileConfigCustomURL.key)

        } catch {
            throw error
        }
    }

    /// Erases custom Omniture URL, and sets the default
    func reset() throws {
        do {
            try decryptedStore.save(item: "", for: Persistent.adobeMobileConfigCustomURL.key)
        } catch {
            throw error
        }
    }
}
