//
//  EntityDataStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/1/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
import RealmSwift
import Foundation

enum Encoding { case encrypted, decrypted }
protocol EntityDataStore {
    var decryptedRealmOnDiskGlobal: Realm? { get }
    func writeToDisk(_ object: Object, encoding: Encoding) -> Promise<Void>
    func writeToMemory(_ object: Object) -> Promise<Void>
    func writeToDisk(_ objects: [Object], encoding: Encoding) -> Promise<Void>
    func writeToMemory(_ objects: [Object]) -> Promise<Void>
    func readObjectFromDisk<T: Object, K>(type: T.Type, forKey: K, encoding: Encoding) -> Promise<T>
    func readObjectFromMemory<T: Object, K>(type: T.Type, forKey: K) -> Promise<T>
    func readObjectsFromDisk<T: Object>(type: T.Type, predicate: String?, encoding: Encoding) -> Promise<Results<T>>
    func readObjectsFromMemory<T: Object>(type: T.Type, predicate: String?) -> Promise<Results<T>>
    func resetDatabase(for encoding: Encoding) -> Promise<Void>
    func delete<T: Object>(type: T.Type, for encoding: Encoding) -> Promise<Void>
}
