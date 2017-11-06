//
//  EntityStore.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/1/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import then
import RealmSwift
import Foundation

protocol EntityStore {
    func writeToDisk(_ object: Object) -> Promise<Void>
    func writeToMemory(_ object: Object) -> Promise<Void>
    func writeToDisk(_ objects: [Object]) -> Promise<Void>
    func writeToMemory(_ objects: [Object]) -> Promise<Void>
    func readObjectFromDisk<T: Object, K>(type: T.Type, forKey: K) -> Promise<T>
    func readObjectFromMemory<T: Object, K>(type: T.Type, forKey: K) -> Promise<T>
    func readObjectsFromDisk<T: Object>(type: T.Type, predicate: String?) -> Promise<Results<T>>
    func readObjectsFromMemory<T: Object>(type: T.Type, predicate: String?) -> Promise<Results<T>>
}
