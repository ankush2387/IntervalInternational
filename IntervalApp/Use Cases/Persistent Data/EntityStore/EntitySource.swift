//
//  EntitySource.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/30/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
import RealmSwift
import Foundation

final class EntitySource {
    
    // MARK: - Public properties
    static let sharedInstance = EntitySource()

    // MARK: - Private properties
    private var contactID: String?
    private var encryptionKey: Data?
    fileprivate var decryptedRealmOnDiskAppGlobal = try? Realm()
    
    // Realm is a MVCC database i.e Uses atomic commits for snapshots of data changes
    // Realm read transaction lifetimes are tied to the memory lifetime of Realm instances
    // The computed variables below will create new instances for safe concurrency access to the data
    
    fileprivate var inMemoryRealm: Realm? {
        let identifier = "\(contactID ?? "Unregistered").realm"
        let inMemoryRealmConfiguration = Realm.Configuration(inMemoryIdentifier: identifier)
        return try? Realm(configuration: inMemoryRealmConfiguration)
    }
    
    fileprivate var encryptedRealmOnDisk: Realm? {
        let path = "\(contactID ?? "Unregistered").realm"
        var encryptedRealmConfiguration = Realm.Configuration(encryptionKey: encryptionKey)
        encryptedRealmConfiguration.fileURL?.deleteLastPathComponent()
        encryptedRealmConfiguration.fileURL = encryptedRealmConfiguration.fileURL?.appendingPathComponent(path)
        return try? Realm(configuration: encryptedRealmConfiguration)
    }
    
    // MARK: - Lifecycle
    private init() { /* Private constructor for correct singleton pattern */ }
    
    // MARK: - Public functions
    func setDatabases(for contactID: String, with encryptionKey: Data) {
        self.contactID = contactID
        self.encryptionKey = encryptionKey
    }

    // MARK: - Private functions
    fileprivate func write(object: Object, to realm: Realm?) -> Promise<Void> {
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

    fileprivate func write(objects: [Object], to realm: Realm?) -> Promise<Void> {
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
    
    fileprivate func readObject<T: Object, K>(type: T.Type, in realm: Realm?, for key: K) -> Promise<T> {
        guard let realm = realm else { return Promise.reject(CommonErrors.emptyInstance) }
        return Promise { resolve, reject in
            if let object = realm.object(ofType: type, forPrimaryKey: key) {
                resolve(object)
            } else {
                reject(CommonErrors.nilDataError)
            }
        }
    }
    
    fileprivate func readObjects<T: Object>(type: T.Type, in realm: Realm?, predicate: String? = nil) -> Promise<Results<T>> {
        guard let realm = realm else { return Promise.reject(CommonErrors.emptyInstance) }
        if let predicate = predicate {
            return Promise.resolve(realm.objects(type).filter(predicate))
        } else {
            return Promise.resolve(realm.objects(type))
        }
    }
}

extension EntitySource: EntityStore {
    
    /// Writes object to RAM, data will not persist between App launches
    func writeToMemory(_ object: Object) -> Promise<Void> {
        return write(object: object, to: inMemoryRealm)
    }
    
    /// Writes objects to RAM, data will not persist between App launches
    func writeToMemory(_ objects: [Object]) -> Promise<Void> {
        return write(objects: objects, to: inMemoryRealm)
    }
    
    /// Writes object to disk (encrypted), data will persist between App launches
    func writeToDisk(_ object: Object) -> Promise<Void> {
        return write(object: object, to: encryptedRealmOnDisk)
    }
    
    /// Writes objects to disk (encrypted), data will persist between App launches
    func writeToDisk(_ objects: [Object]) -> Promise<Void> {
        return write(objects: objects, to: encryptedRealmOnDisk)
    }
    
    /// Read object from RAM, data does not persist between App launches
    func readObjectFromMemory<T: Object, K>(type: T.Type, forKey: K) -> Promise<T> {
        return readObject(type: type, in: inMemoryRealm, for: forKey)
    }
    
    /// Read objects from RAM, data does not persist between App launches
    func readObjectsFromMemory<T: Object>(type: T.Type, predicate: String?) -> Promise<Results<T>> {
        return readObjects(type: type, in: inMemoryRealm, predicate: predicate)
    }
    
    /// Read object from disk (encrypted), data persists between App launches
    func readObjectFromDisk<T: Object, K>(type: T.Type, forKey: K) -> Promise<T> {
        return readObject(type: type, in: encryptedRealmOnDisk, for: forKey)
    }
    
    /// Read objects from disk (encrypted), data persists between App launches
    func readObjectsFromDisk<T: Object>(type: T.Type, predicate: String?) -> Promise<Results<T>> {
        return readObjects(type: type, in: encryptedRealmOnDisk, predicate: predicate)
    }
}
