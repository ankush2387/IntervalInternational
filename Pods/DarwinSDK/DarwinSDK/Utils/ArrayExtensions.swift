//
//  ArrayExtensions.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/27/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation

extension Array  {
    
    // Convert Swift Array to Dictionary with indexes
    //
    var indexedDictionary: [Int: Element] {
        var result: [Int: Element] = [:]
        enumerated().forEach({ result[$0.offset] = $0.element })
        return result
    }
    
    /*
    func toDictionary<E, K, V>(array: [E], transformer: (_: E) -> (key: K, value: V)?) -> Dictionary<K, V> {
        return array.reduce([:]) {
            (var dict, e) in
            if let (key, value) = transformer(e)
            {
                dict[key] = value
            }
            return dict
        }
    }
    */
    
    func closetIndexTo(_ to :Int) -> Int {
        var min = Int.max
        var closet = to
        
        for element in self {
            let value: Int = element as! Int
            let diff = value - to

            if diff <= min {
                min = diff
                closet = value
            }
        }
        return abs(closet)
    }
    
}
