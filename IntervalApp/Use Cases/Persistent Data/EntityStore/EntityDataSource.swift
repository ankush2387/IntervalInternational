//
//  EntityDataSource.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/30/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
import RealmSwift
import Foundation

final class EntityDataSource {
    
    // MARK: - Public properties
    static let sharedInstance = EntityDataSource()

    // MARK: - Private properties
    fileprivate var inMemoryRealmConfiguration: Realm.Configuration?
    fileprivate var encryptedRealmConfiguration: Realm.Configuration?
    
    // Realm is a MVCC database i.e Uses atomic commits for snapshots of data changes
    // Realm read transaction lifetimes are tied to the memory lifetime of Realm instances
    // The computed variables below will create new instances for safe concurrency access to the data

    var decryptedRealmOnDiskGlobal: Realm? {
        return try? Realm()
    }

    fileprivate var inMemoryRealm: Realm? {
        guard let inMemoryRealmConfiguration = inMemoryRealmConfiguration else { return nil }
        return try? Realm(configuration: inMemoryRealmConfiguration)
    }
    
    fileprivate var encryptedRealmOnDisk: Realm? {
        guard let encryptedRealmConfiguration = encryptedRealmConfiguration else { return nil }
        return try? Realm(configuration: encryptedRealmConfiguration)
    }
    
    // MARK: - Lifecycle
    private init() { /* Private constructor for correct singleton pattern */ }
    
    // MARK: - Public functions
    func setDatabaseConfigurations(for contactID: String, with encryptionKey: Data) {
        let path = "\(contactID).realm"
        inMemoryRealmConfiguration = Realm.Configuration(inMemoryIdentifier: path)
        encryptedRealmConfiguration = Realm.Configuration(encryptionKey: encryptionKey)
        encryptedRealmConfiguration?.fileURL?.deleteLastPathComponent()
        let fileURL = encryptedRealmConfiguration?.fileURL?.appendingPathComponent(path)
        encryptedRealmConfiguration?.fileURL = fileURL

        encryptedRealmConfiguration?.shouldCompactOnLaunch = { totalBytes, usedBytes in
            // totalBytes refers to the size of the file on disk in bytes (data + free space)
            // usedBytes refers to the number of bytes used by data in the file
            // Happens when realm database is opened for the first time
            // Compact if the file is over 100MB in size and less than 50% 'used'
            let oneHundredMB = 100 * 1024 * 1024
            return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
        }
    }

    // MARK: - Private functions
    fileprivate func write(_ object: Object, to realm: Realm?) -> Promise<Void> {
        guard let realm = realm else { return Promise.reject(CommonErrors.emptyInstance) }
        return Promise { resolve, reject in
            do {
                try realm.write {
                    realm.add(object)
                    resolve()
                }

            } catch {
                reject(error)
            }
        }
    }

    fileprivate func write(_ objects: [Object], to realm: Realm?) -> Promise<Void> {
        guard let realm = realm else { return Promise.reject(CommonErrors.emptyInstance) }
        return Promise { resolve, reject in
            do {
                try realm.write {
                    realm.add(objects)
                    resolve()
                }
                
            } catch {
                reject(error)
            }
        }
    }
    
    fileprivate func readObject<T: Object, K>(_ type: T.Type, in realm: Realm?, for key: K) -> Promise<T> {
        guard let realm = realm else { return Promise.reject(CommonErrors.emptyInstance) }
        return Promise { resolve, reject in
            if let object = realm.object(ofType: type, forPrimaryKey: key) {
                resolve(object)
            } else {
                reject(CommonErrors.nilDataError)
            }
        }
    }
    
    fileprivate func readObjects<T: Object>(_ type: T.Type, in realm: Realm?, with predicate: String? = nil) -> Promise<Results<T>> {
        guard let realm = realm else { return Promise.reject(CommonErrors.emptyInstance) }
        if let predicate = predicate {
            return Promise.resolve(realm.objects(type).filter(predicate))
        } else {
            return Promise.resolve(realm.objects(type))
        }
    }
    
    fileprivate func resetDatabase(for realm: Realm?) -> Promise<Void> {
        return Promise { resolve, reject in
            guard let realm = realm else {
                reject(CommonErrors.emptyInstance)
                return
            }
            
            do {
                try realm.write {
                    realm.deleteAll()
                    resolve()
                }
            } catch {
                reject(error)
            }
        }
    }
}

extension EntityDataSource: EntityDataStore {
    
    /// Writes object to RAM, data will not persist between App launches
    func writeToMemory(_ object: Object) -> Promise<Void> {
        return write(object, to: inMemoryRealm)
    }
    
    /// Writes objects to RAM, data will not persist between App launches
    func writeToMemory(_ objects: [Object]) -> Promise<Void> {
        return write(objects, to: inMemoryRealm)
    }
    
    /// Writes object to disk (encrypted), data will persist between App launches
    func writeToDisk(_ object: Object, encoding: Encoding) -> Promise<Void> {
        let database = encoding == .encrypted ? encryptedRealmOnDisk : decryptedRealmOnDiskGlobal
        return write(object, to: database)
    }
    
    /// Writes objects to disk (encrypted), data will persist between App launches
    func writeToDisk(_ objects: [Object], encoding: Encoding) -> Promise<Void> {
        let database = encoding == .encrypted ? encryptedRealmOnDisk : decryptedRealmOnDiskGlobal
        return write(objects, to: database)
    }
    
    /// Read object from RAM, data does not persist between App launches
    func readObjectFromMemory<T: Object, K>(type: T.Type, forKey: K) -> Promise<T> {
        return readObject(type, in: inMemoryRealm, for: forKey)
    }
    
    /// Read objects from RAM, data does not persist between App launches
    func readObjectsFromMemory<T: Object>(type: T.Type, predicate: String?) -> Promise<Results<T>> {
        return readObjects(type, in: inMemoryRealm, with: predicate)
    }
    
    /// Read object from disk (encrypted), data persists between App launches
    func readObjectFromDisk<T: Object, K>(type: T.Type, forKey: K, encoding: Encoding) -> Promise<T> {
        let database = encoding == .encrypted ? encryptedRealmOnDisk : decryptedRealmOnDiskGlobal
        return readObject(type, in: database, for: forKey)
    }
    
    /// Read objects from disk (encrypted), data persists between App launches
    func readObjectsFromDisk<T: Object>(type: T.Type, predicate: String?, encoding: Encoding) -> Promise<Results<T>> {
        let database = encoding == .encrypted ? encryptedRealmOnDisk : decryptedRealmOnDiskGlobal
        return readObjects(type, in: database, with: predicate)
    }
    
    /// Reset database for realm in specified encoding
    func resetDatabase(for encoding: Encoding) -> Promise<Void> {
        let realm = encoding == .encrypted ? encryptedRealmOnDisk : decryptedRealmOnDiskGlobal
        return resetDatabase(for: realm)
    }
}
