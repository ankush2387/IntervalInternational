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
    var customURLPathBeingUsed: Bool {
        guard let path = try? decryptedStore.getItem(for: Persistent.adobeMobileConfig.key, ofType: String()) else {
            return false
        }

        return !path.unwrappedString.isEmpty
    }

    var path: String? {

        guard let path = try? decryptedStore.getItem(for: Persistent.adobeMobileConfig.key, ofType: String()),
        !path.unwrappedString.isEmpty else {
            return directoryForOriginalConfigFile?.absoluteString
        }

        return path
    }

    // MARK: - Private properties
    private let decryptedStore: DecryptedItemDataStore
    private let directoryForOriginalConfigFile = Bundle.main.url(forResource: "ADBMobileConfig", withExtension: "json")
    private var documentsDirectory: URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.last
    }

    // MARK: - Lifecycle
    init(decryptedStore: DecryptedItemDataStore) {
        self.decryptedStore = decryptedStore
    }

    init() {
        self.init(decryptedStore: UserDafaultsWrapper())
    }

    // MARK: - Public functions
    /// Sets a custom Omniture URL
    func set(server: String, useSSL: Bool) throws {
        
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
            
            analytics["server"] = server
            analytics["ssl"] = useSSL
            object["analytics"] = analytics

            guard JSONSerialization.isValidJSONObject(object) else {
                throw CommonErrors.unsupportedData
            }

            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)

            guard let json = jsonString else {
                throw CommonErrors.parsingError
            }

            guard let directory = documentsDirectory else {
                throw CommonErrors.emptyInstance
            }

            let filename = directory.appendingPathComponent("ADBMobileConfig.json")
            try json.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            try decryptedStore.save(item: filename.absoluteString, for: Persistent.adobeMobileConfig.key)

        } catch {
            throw error
        }
    }

    /// Erases custom Omniture URL, and sets the default
    func reset() throws {
        return try decryptedStore.save(item: "", for: Persistent.adobeMobileConfig.key)
    }
}
